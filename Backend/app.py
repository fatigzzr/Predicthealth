import os
import re
import json

from flask import Flask, request, jsonify
from flask_cors import CORS
from psycopg2 import pool
import psycopg2
import jwt
from functools import wraps
from datetime import datetime, timedelta


# -----------------------------------------------------------------------------
# App configuration
# -----------------------------------------------------------------------------
app = Flask(__name__)
CORS(
    app,
    resources={r"/api/*": {"origins": "http://localhost:3000"}},
    supports_credentials=True,
    methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)


# -----------------------------------------------------------------------------
# Database configuration (PostgreSQL connection pool)
# -----------------------------------------------------------------------------
PG_HOST = os.getenv("PGHOST", "localhost")
PG_PORT = int(os.getenv("PGPORT", "5432"))
PG_DB = os.getenv("PGDATABASE", "predicthealth")
PG_USER = os.getenv("PGUSER", "predicthealth_user")
PG_PASS = os.getenv("PGPASSWORD", "666")

_db_pool = None


def _init_db_pool():
    global _db_pool
    if _db_pool is None:
        dsn = (
            f"host={PG_HOST} port={PG_PORT} dbname={PG_DB} "
            f"user={PG_USER} password={PG_PASS}"
        )
        _db_pool = pool.SimpleConnectionPool(minconn=1, maxconn=5, dsn=dsn)
    return _db_pool


def get_db_conn():
    return _init_db_pool().getconn()


def put_db_conn(conn):
    if _db_pool and conn:
        try:
            _db_pool.putconn(conn)
        except Exception as e:
            print(f"Error putting connection back to pool: {e}")
            # Si no se puede devolver al pool, cerrar la conexión
            try:
                conn.close()
            except:
                pass




# -----------------------------------------------------------------------------
# Health endpoints
# -----------------------------------------------------------------------------
@app.route("/api/health")
def health():
    return jsonify({"status": "ok"})


# -----------------------------------------------------------------------------
# Audit logging helper
# -----------------------------------------------------------------------------
def log_audit_action(user_id, entity_id, action, details=None):
    """
    Log an audit action to the Registro_Auditoria table.
    
    Args:
        user_id: ID of the user performing the action (can be None for anonymous actions)
        entity_id: ID of the entity being accessed
        action: Action type ('CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT')
        details: Optional JSON details about the action
    """
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Convert details dict to JSON string if provided
        details_json = json.dumps(details) if details else None
        
        # Insert audit record using stored procedure
        cur.execute(
            "CALL sp_insert_audit_record(%s, %s, %s, %s)",
            (user_id, entity_id, action, details_json)
        )
        conn.commit()
    except psycopg2.Error as e:
        # Don't fail the main operation if audit logging fails
        print(f"Audit logging failed: {e}")
        if conn:
            conn.rollback()
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


def get_entity_id_by_name(cur, entity_name):
    """Get entity ID by entity name using stored procedure"""
    try:
        cur.execute("CALL sp_get_entity_id_by_name(%s, %s)", (entity_name, None))
        result = cur.fetchone()
        return result[0] if result else None
    except psycopg2.Error:
        return None


# -----------------------------------------------------------------------------
# Auth (JWT) and Login
# -----------------------------------------------------------------------------
JWT_SECRET = os.getenv("JWT_SECRET", "dev-secret-change-me")
JWT_EXPIRES_MIN = int(os.getenv("JWT_EXPIRES_MIN", "60"))


def create_jwt(payload: dict) -> str:
    exp = datetime.utcnow() + timedelta(minutes=JWT_EXPIRES_MIN)
    to_encode = {**payload, "exp": exp}
    token = jwt.encode(to_encode, JWT_SECRET, algorithm="HS256")
    return token


def auth_required(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        auth_header = request.headers.get("Authorization", "")
        parts = auth_header.split()
        if len(parts) != 2 or parts[0].lower() != "bearer":
            return jsonify({"error": "missing_or_invalid_token"}), 401
        token = parts[1]
        try:
            claims = jwt.decode(token, JWT_SECRET, algorithms=["HS256"]) 
        except jwt.ExpiredSignatureError:
            return jsonify({"error": "token_expired"}), 401
        except jwt.InvalidTokenError:
            return jsonify({"error": "invalid_token"}), 401
        request.user = claims
        return f(*args, **kwargs)
    return wrapper


@app.route("/api/login", methods=["POST"])
def login_route():
    data = request.get_json(silent=True) or {}
    # Frontend puede enviar 'username' y 'password'; usamos 'username' como alias de email
    email = data.get("email") or data.get("username")
    password = data.get("password")
    if not email or not password:
        return jsonify({"error": "email_and_password_required"}), 400

    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Obtener IP real del request
        ip_address = request.environ.get('HTTP_X_FORWARDED_FOR', request.environ.get('REMOTE_ADDR', 'unknown'))
        
        # Llamar al procedimiento almacenado (solo personal autorizado)
        cur.execute(
            "CALL sp_login_staff(%s, %s, %s, %s, %s, %s, %s)",
            (email, password, ip_address, None, None, None, None)
        )
        # Obtener los valores de salida
        result = cur.fetchone()
        if not result or not result[3]:  # p_success es el último parámetro (índice 3)
            return jsonify({"error": "invalid_credentials"}), 401
        
        user_id, user_email, role_id = result[0], result[1], result[2]
        token = create_jwt({"sub": str(user_id), "email": user_email, "roleId": role_id})
        
        # Log successful login
        log_audit_action(
            user_id=user_id,
            entity_id=None,  # Login doesn't target a specific entity
            action='LOGIN',
            details={
                "email": user_email,
                "role_id": role_id,
                "ip_address": ip_address,
                "timestamp": datetime.utcnow().isoformat()
            }
        )
        
        return jsonify({
            "token": token, 
            "user": {
                "id": user_id, 
                "email": user_email, 
                "roleId": role_id
            }
        })
    except psycopg2.Error as e:
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/me")
def me_route():
    # Debug: verificar el header
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return jsonify({"error": "missing_or_invalid_token"}), 401
    
    token = auth_header.split(" ")[1]
    try:
        claims = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        user_id = int(claims.get("sub"))
        if not user_id:
            return jsonify({"error": "invalid_token"}), 401
    except jwt.ExpiredSignatureError:
        return jsonify({"error": "token_expired"}), 401
    except jwt.InvalidTokenError:
        return jsonify({"error": "invalid_token"}), 401
    
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Llamar al procedimiento almacenado
        cur.execute(
            "CALL sp_get_user_data(%s, %s, %s, %s, %s)",
            (user_id, None, None, None, None)
        )
        # Obtener los valores de salida
        result = cur.fetchone()
        if not result or not result[3]:  # p_success es el último parámetro (índice 3)
            return jsonify({"error": "user_not_found"}), 404
        
        email, role_id, role_name = result[0], result[1], result[2]
        return jsonify({
            "id": user_id, 
            "email": email, 
            "roleId": role_id, 
            "role": role_name
        })
    except psycopg2.Error as e:
        print(f"Database error in /api/me: {e}")
        if conn:
            try:
                conn.rollback()
            except:
                pass
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    except Exception as e:
        print(f"Unexpected error in /api/me: {e}")
        if conn:
            try:
                conn.rollback()
            except:
                pass
        return jsonify({"error": f"unexpected_error: {str(e)}"}), 500
    finally:
        try:
            if cur:
                cur.close()
        except:
            pass
        try:
            if conn:
                put_db_conn(conn)
        except Exception as e:
            print(f"Error returning connection to pool: {e}")


# -----------------------------------------------------------------------------
# Database Entities endpoints
# -----------------------------------------------------------------------------
@app.route("/api/entidades", methods=["GET"])
@auth_required
def get_entidades():
    """Obtener todas las entidades (tablas) de la base de datos"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Usar transacción para manejar el cursor correctamente
        cur.execute("BEGIN;")
        cur.execute("CALL sp_get_entidades('p_entidades');")
        cur.execute("FETCH ALL FROM p_entidades;")
        entidades = cur.fetchall()
        cur.execute("COMMIT;")
        
        # Convertir a formato JSON
        entidades_list = []
        for entidad in entidades:
            entidades_list.append({
                "id": entidad[0],
                "nombre": entidad[1]
            })
        
        
        return jsonify({
            "success": True,
            "entidades": entidades_list,
            "total": len(entidades_list)
        })
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/entidades/<entidad_name>", methods=["GET"])
@auth_required
def get_entidad_data(entidad_name):
    """Obtener datos de una entidad específica - tabla completa"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Usar transacción para manejar el cursor correctamente
        cur.execute("BEGIN;")
        cur.execute("CALL sp_get_entidad_data_with_columns(%s, 'p_datos', 'p_columnas')", (entidad_name,))
        cur.execute("FETCH ALL FROM p_datos;")
        data = cur.fetchall()
        cur.execute("FETCH ALL FROM p_columnas;")
        columns_info = cur.fetchall()
        cur.execute("COMMIT;")
        
        # Convertir a formato JSON simple
        data_list = []
        for row in data:
            data_list.append(list(row))
        
        # Extraer nombres de columnas
        column_names = [col[0] for col in columns_info]
        
        
        return jsonify({
            "success": True,
            "entidad": entidad_name,
            "datos": data_list,
            "columnas": column_names,
            "total": len(data_list)
        })
        
    except psycopg2.Error as e:
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)



# -----------------------------------------------------------------------------
# Delete records from a specific table
# -----------------------------------------------------------------------------
def _table_exists(cur, table_name: str, schema: str = "public") -> bool:
    cur.execute("CALL sp_table_exists(%s, %s, %s)", (schema, table_name, None))
    row = cur.fetchone()
    return bool(row[0]) if row else False


def _get_primary_key_column(cur, table_name: str, schema: str = "public"):
    """Return the primary key column name for a given table, or None if not found."""
    cur.execute("CALL sp_get_primary_key_column(%s, %s, %s)", (schema, table_name, None))
    row = cur.fetchone()
    return row[0] if row else None

def _get_primary_key_columns(cur, table_name: str, schema: str = "public"):
    cur.execute("CALL sp_get_primary_key_columns(%s, %s, %s)", (schema, table_name, None))
    row = cur.fetchone()
    return row[0] if row else []


def _is_safe_identifier(name: str) -> bool:
    """Basic check to reduce risk when composing identifiers dynamically."""
    return bool(re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", name or ""))


def _get_table_columns(cur, table_name: str, schema: str = "public"):
    """Return ordered list of column names for a given table using SP."""
    # Usar cursor de ref para seguir el mismo patrón que otros SP
    cur.execute("BEGIN;")
    cur.execute("CALL sp_get_table_columns(%s, %s, 'p_columns');", (schema, table_name))
    cur.execute("FETCH ALL FROM p_columns;")
    rows = cur.fetchall() or []
    cur.execute("COMMIT;")
    return [r[0] for r in rows]


@app.route("/api/entidades/<entidad_name>/pk-columns", methods=["GET"])
@auth_required
def get_pk_columns(entidad_name):
    """Obtener columnas de la clave primaria para una entidad"""
    if not _is_safe_identifier(entidad_name):
        return jsonify({"error": "invalid_table_name"}), 400
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()

        # Resolver nombre respetando mayúsculas
        resolved_table = entidad_name if _table_exists(cur, entidad_name) else entidad_name.lower()
        if not _table_exists(cur, resolved_table):
            return jsonify({"error": "table_not_found"}), 404

        cols = _get_primary_key_columns(cur, resolved_table) or []
        return jsonify({"success": True, "pkColumns": cols})
    except psycopg2.Error as e:
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/entidades/<entidad_name>/<pk_value>", methods=["DELETE"])
@auth_required
def delete_record_by_id(entidad_name, pk_value):
    """Eliminar un registro por id usando la PK de la tabla."""
    if not _is_safe_identifier(entidad_name):
        return jsonify({"error": "invalid_table_name"}), 400

    # Normalizar variantes del nombre de tabla
    entidad_lc = entidad_name.lower()

    # Bloquear autodestrucción del usuario autenticado en tabla Usuario
    try:
        current_user_id = str((request.user or {}).get("sub")) if hasattr(request, "user") else None
    except Exception:
        current_user_id = None

    if entidad_lc == "usuario" and current_user_id and str(pk_value) == current_user_id:
        return jsonify({"error": "cannot_delete_current_user"}), 403

    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()

        # Resolver nombre de tabla respetando mayúsculas si existe entrecomillada
        resolved_table = entidad_name
        if not _table_exists(cur, resolved_table):
            if _table_exists(cur, entidad_lc):
                resolved_table = entidad_lc
            else:
                return jsonify({"error": "table_not_found"}), 404

        pk_column = _get_primary_key_column(cur, resolved_table)
        if not pk_column:
            return jsonify({"error": "primary_key_not_found"}), 400

        # Si es PK compuesta, requerir todos los componentes por query params ?pk_<col>=valor
        pk_columns = _get_primary_key_columns(cur, resolved_table)
        if isinstance(pk_columns, list) and len(pk_columns) > 1:
            values = []
            missing = []
            for col in pk_columns:
                val = request.args.get(f"pk_{col}")
                if val is None:
                    missing.append(col)
                else:
                    values.append(val)
            if missing:
                return jsonify({
                    "error": "composite_pk_values_required",
                    "missing": missing,
                    "hint": "Proporciona ?pk_col=value para cada columna de la PK"
                }, "error", 400)

            # Llamar SP para PK compuesta
            cur.execute(
                "CALL sp_delete_by_pk_multi(%s, %s, %s, %s, %s, %s)",
                (resolved_table, pk_columns, values, None, None, None),
            )
            result = cur.fetchone()
            conn.commit()
            if not result:
                return jsonify({"error": "unexpected_no_result"}), 500
            deleted_count, success, error_msg = result[0], result[1], result[2]
            if not success:
                status = 404 if deleted_count == 0 else 400
                return jsonify({"success": False, "deleted": int(deleted_count), "error": error_msg}), status
            return jsonify({"success": True, "deleted": int(deleted_count)})

        # Llamar al procedimiento almacenado genérico de borrado por PK
        cur.execute(
            "CALL sp_delete_by_pk(%s, %s, %s, %s, %s, %s)",
            (resolved_table, pk_column, str(pk_value), None, None, None),
        )
        result = cur.fetchone()
        conn.commit()

        if not result:
            return jsonify({"error": "unexpected_no_result"}), 500

        deleted_count, success, error_msg = result[0], result[1], result[2]
        if not success:
            status = 404 if deleted_count == 0 else 400
            return jsonify({"success": False, "deleted": int(deleted_count), "error": error_msg}), status

        # Log successful delete operation
        user_id = getattr(request, 'user', {}).get('sub')
        entity_id = get_entity_id_by_name(cur, resolved_table)
        log_audit_action(
            user_id=user_id,
            entity_id=entity_id,
            action='DELETE',
            details={
                "operation": "delete_record",
                "entity_name": resolved_table,
                "pk_column": pk_column,
                "pk_value": str(pk_value),
                "deleted_count": int(deleted_count),
                "timestamp": datetime.utcnow().isoformat()
            }
        )

        return jsonify({"success": True, "deleted": int(deleted_count)})
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/entidades/<entidad_name>/<pk_value>", methods=["PUT", "PATCH"])
@auth_required
def update_record_by_id(entidad_name, pk_value):
    """Actualizar un registro por PK. Soporta PK compuesta usando query params ?pk_col=value.

    Cuerpo JSON: { "columna": valor, ... } con las columnas a actualizar.
    Las columnas de PK serán ignoradas si se incluyen en el body.
    """
    if not _is_safe_identifier(entidad_name):
        return jsonify({"error": "invalid_table_name"}), 400

    data = request.get_json(silent=True) or {}
    if not isinstance(data, dict) or not data:
        return jsonify({"error": "empty_body: Proporciona un JSON con campos a actualizar"}), 400

    entidad_lc = entidad_name.lower()

    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()

        # Resolver nombre de tabla respetando mayúsculas si existe entrecomillada
        resolved_table = entidad_name if _table_exists(cur, entidad_name) else (entidad_lc if _table_exists(cur, entidad_lc) else None)
        if not resolved_table:
            return jsonify({"error": "table_not_found"}), 404

        # Descubrir columnas y PK
        all_columns = _get_table_columns(cur, resolved_table) or []
        if not all_columns:
            return jsonify({"error": "columns_not_found"}), 400

        pk_columns = _get_primary_key_columns(cur, resolved_table)
        pk_columns = pk_columns if isinstance(pk_columns, list) else ([pk_columns] if pk_columns else [])
        if not pk_columns:
            # Fallback a PK simple detectada por helper alterno
            pk_single = _get_primary_key_column(cur, resolved_table)
            if pk_single:
                pk_columns = [pk_single]
        if not pk_columns:
            return jsonify({"error": "primary_key_not_found"}), 400

        # Filtrar campos actualizables: existentes y que no sean PK
        updatable_items = [(k, v) for k, v in data.items() if isinstance(k, str) and k in all_columns and k not in pk_columns]
        if not updatable_items:
            return jsonify({"error": "no_updatable_fields: Asegúrate de enviar columnas válidas distintas a la PK"}), 400

        # Preparar arrays de columnas/valores a actualizar
        update_columns = [col for col, _ in updatable_items]
        update_values = [val for _, val in updatable_items]

        # Invocar SP de actualización según PK simple o compuesta
        if len(pk_columns) == 1:
            pk_col = pk_columns[0]
            cur.execute(
                "CALL sp_update_by_pk(%s, %s, %s, %s, %s, %s, %s, %s)",
                (resolved_table, pk_col, str(pk_value), update_columns, update_values, None, None, None),
            )
            result = cur.fetchone()
        else:
            # Obtener valores de PK compuesta desde query params
            missing = []
            values = []
            for col in pk_columns:
                val = request.args.get(f"pk_{col}")
                if val is None:
                    missing.append(col)
                else:
                    values.append(val)
            if missing:
                return jsonify({
                    "error": "composite_pk_values_required",
                    "missing": missing,
                    "hint": "Proporciona ?pk_col=value para cada columna de la PK"
                }, "error", 400)

            cur.execute(
                "CALL sp_update_by_pk_multi(%s, %s, %s, %s, %s, %s, %s, %s)",
                (resolved_table, pk_columns, values, update_columns, update_values, None, None, None),
            )
            result = cur.fetchone()

        conn.commit()

        if not result:
            return jsonify({"error": "unexpected_no_result"}), 500

        updated_count, success, error_msg = result[0], result[1], result[2]
        if not success:
            status = 404 if int(updated_count or 0) == 0 else 400
            return jsonify({"success": False, "updated": int(updated_count or 0), "error": error_msg}), status

        # Log successful update operation
        user_id = getattr(request, 'user', {}).get('sub')
        entity_id = get_entity_id_by_name(cur, resolved_table)
        log_audit_action(
            user_id=user_id,
            entity_id=entity_id,
            action='UPDATE',
            details={
                "operation": "update_record",
                "entity_name": resolved_table,
                "updated_columns": update_columns,
                "updated_values": update_values,
                "updated_count": int(updated_count or 0),
                "timestamp": datetime.utcnow().isoformat()
            }
        )

        return jsonify({"success": True, "updated": int(updated_count or 0)})
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


# -----------------------------------------------------------------------------
# Insert records into specific tables
# -----------------------------------------------------------------------------
@app.route("/api/entidades/<entidad_name>", methods=["POST"])
@auth_required
def insert_record(entidad_name):
    """Insertar un nuevo registro en una tabla específica"""
    if not _is_safe_identifier(entidad_name):
        return jsonify({"error": "invalid_table_name"}), 400

    data = request.get_json(silent=True) or {}
    if not isinstance(data, dict) or not data:
        return jsonify({"error": "empty_body: Proporciona un JSON con los campos a insertar"}), 400

    entidad_lc = entidad_name.lower()

    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()

        # Resolver nombre de tabla respetando mayúsculas si existe entrecomillada
        resolved_table = entidad_name if _table_exists(cur, entidad_name) else (entidad_lc if _table_exists(cur, entidad_lc) else None)
        if not resolved_table:
            return jsonify({"error": "table_not_found"}), 404

        # Obtener columnas de la tabla
        all_columns = _get_table_columns(cur, resolved_table) or []
        if not all_columns:
            return jsonify({"error": "columns_not_found"}), 400

        # Filtrar campos válidos que existen en la tabla
        valid_items = [(k, v) for k, v in data.items() if isinstance(k, str) and k in all_columns]
        if not valid_items:
            return jsonify({"error": "no_valid_fields: Asegúrate de enviar columnas válidas de la tabla"}), 400

        # Preparar arrays de columnas/valores a insertar
        insert_columns = [col for col, _ in valid_items]
        insert_values = [val for _, val in valid_items]

        # Llamar al procedimiento almacenado genérico de inserción
        cur.execute(
            "CALL sp_insert_record(%s, %s, %s, %s, %s, %s)",
            (resolved_table, insert_columns, insert_values, None, None, None),
        )
        result = cur.fetchone()
        conn.commit()

        if not result:
            return jsonify({"error": "unexpected_no_result"}), 500

        inserted_id, success, error_msg = result[0], result[1], result[2]
        if not success:
            return jsonify({"success": False, "error": error_msg}), 400

        # Log successful insert operation
        user_id = getattr(request, 'user', {}).get('sub')
        entity_id = get_entity_id_by_name(cur, resolved_table)
        log_audit_action(
            user_id=user_id,
            entity_id=entity_id,
            action='CREATE',
            details={
                "operation": "insert_record",
                "entity_name": resolved_table,
                "inserted_columns": insert_columns,
                "inserted_values": insert_values,
                "inserted_id": inserted_id,
                "timestamp": datetime.utcnow().isoformat()
            }
        )

        return jsonify({"success": True, "inserted_id": inserted_id})
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


# -----------------------------------------------------------------------------
# Dashboard endpoints using stored procedures
# -----------------------------------------------------------------------------

@app.route("/api/dashboard/monitoreo-pa", methods=["GET"])
@auth_required
def get_dashboard_monitoreo_pa():
    """Dashboard 1: Monitoreo PA Completo"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Usar transacción para manejar el cursor
        cur.execute("BEGIN;")
        cur.execute("CALL sp_dashboard_monitoreo_pa('cursor_result');")
        cur.execute("FETCH ALL FROM cursor_result;")
        data = cur.fetchall()
        cur.execute("COMMIT;")
        
        # Procesar datos para que sean serializables
        processed_data = []
        for row in data:
            processed_data.append(list(row))
        
        return jsonify({
            "success": True,
            "dashboard": "monitoreo-pa",
            "data": processed_data,
            "total": len(processed_data)
        })
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/dashboard/monitoreo-pa-stats", methods=["GET"])
@auth_required
def get_dashboard_monitoreo_pa_stats():
    """Dashboard 1: Estadísticas de Monitoreo PA"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Usar transacción para manejar el cursor
        cur.execute("BEGIN;")
        cur.execute("CALL sp_dashboard_monitoreo_pa('cursor_result');")
        cur.execute("FETCH ALL FROM cursor_result;")
        data = cur.fetchall()
        cur.execute("COMMIT;")
        
        # Procesar datos para calcular estadísticas
        if not data:
            return jsonify({
                "success": True,
                "dashboard": "monitoreo-pa-stats",
                "stats": {
                    "totalRegistros": 0,
                    "sistolicaPromedio": 0,
                    "diastolicaPromedio": 0,
                    "sistolicaMin": 0,
                    "sistolicaMax": 0,
                    "diastolicaMin": 0,
                    "diastolicaMax": 0
                }
            })
        
        # Convertir datos a objetos con propiedades nombradas
        processed_data = []
        for item in data:
            processed_data.append({
                "id_usuario": item[0],
                "fecha": item[1],
                "id_postura": item[2],
                "id_dispositivo": item[3],
                "bp_sistolica_promedio": item[4],
                "bp_sistolica_min": item[5],
                "bp_sistolica_max": item[6],
                "bp_diastolica_promedio": item[7],
                "bp_diastolica_min": item[8],
                "bp_diastolica_max": item[9]
            })
        
        # Calcular estadísticas
        all_systolic = [item["bp_sistolica_promedio"] for item in processed_data if item["bp_sistolica_promedio"]]
        all_diastolic = [item["bp_diastolica_promedio"] for item in processed_data if item["bp_diastolica_promedio"]]
        
        stats = {
            "totalRegistros": len(processed_data),
            "sistolicaPromedio": round(sum(all_systolic) / len(all_systolic), 1) if all_systolic else 0,
            "diastolicaPromedio": round(sum(all_diastolic) / len(all_diastolic), 1) if all_diastolic else 0,
            "sistolicaMin": round(min(all_systolic), 1) if all_systolic else 0,
            "sistolicaMax": round(max(all_systolic), 1) if all_systolic else 0,
            "diastolicaMin": round(min(all_diastolic), 1) if all_diastolic else 0,
            "diastolicaMax": round(max(all_diastolic), 1) if all_diastolic else 0
        }
        
        return jsonify({
            "success": True,
            "dashboard": "monitoreo-pa-stats",
            "stats": stats
        }, "dashboard_monitoreo_pa_stats")
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    except Exception as e:
        return jsonify({"error": f"processing_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/dashboard/signos-vitales", methods=["GET"])
@auth_required
def get_dashboard_signos_vitales():
    """Dashboard 2: Signos Vitales"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Usar transacción para manejar el cursor
        cur.execute("BEGIN;")
        cur.execute("CALL sp_dashboard_signos_vitales('cursor_result');")
        cur.execute("FETCH ALL FROM cursor_result;")
        data = cur.fetchall()
        cur.execute("COMMIT;")
        
        # Procesar datos para que sean serializables
        processed_data = []
        for row in data:
            processed_data.append(list(row))
        
        return jsonify({
            "success": True,
            "dashboard": "signos-vitales",
            "data": processed_data,
            "total": len(processed_data)
        })
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/dashboard/lab", methods=["GET"])
@auth_required
def get_dashboard_lab():
    """Dashboard 3: Laboratorio"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Usar transacción para manejar el cursor
        cur.execute("BEGIN;")
        cur.execute("CALL sp_dashboard_lab('cursor_result');")
        cur.execute("FETCH ALL FROM cursor_result;")
        data = cur.fetchall()
        cur.execute("COMMIT;")
        
        # Procesar datos para que sean serializables
        processed_data = []
        for row in data:
            processed_data.append(list(row))
        
        return jsonify({
            "success": True,
            "dashboard": "lab",
            "data": processed_data,
            "total": len(processed_data)
        })
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/dashboard/lab/stats", methods=["GET"])
@auth_required
def get_dashboard_lab_stats():
    """Dashboard: Estadísticas de Laboratorio"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Usar transacción para manejar el cursor
        cur.execute("BEGIN;")
        cur.execute("CALL sp_dashboard_lab('cursor_result');")
        cur.execute("FETCH ALL FROM cursor_result;")
        data = cur.fetchall()
        cur.execute("COMMIT;")
        
        # Procesar datos para calcular estadísticas
        if not data:
            return jsonify({
                "success": True,
                "dashboard": "lab-stats",
                "stats": {
                    "totalRegistros": 0,
                    "colesterolPromedio": 0,
                    "hdlPromedio": 0,
                    "ldlPromedio": 0,
                    "trigliceridosPromedio": 0,
                    "colesterolMin": 0,
                    "colesterolMax": 0,
                    "hdlMin": 0,
                    "hdlMax": 0,
                    "ldlMin": 0,
                    "ldlMax": 0
                }
            })
        
        # Convertir datos a objetos con propiedades nombradas
        processed_data = []
        for item in data:
            # Asegurar que cada elemento sea serializable, manteniendo tipos numéricos
            processed_item = []
            for i in range(len(item)):
                if item[i] is None:
                    processed_item.append(None)
                elif isinstance(item[i], (int, float, bool)):
                    processed_item.append(item[i])
                elif isinstance(item[i], str):
                    processed_item.append(item[i])
                else:
                    # Convertir a string solo si no es un tipo básico
                    processed_item.append(str(item[i]))
            
            processed_data.append({
                "id_usuario": processed_item[0],
                "fecha": processed_item[1],
                "analito": processed_item[2],
                "valor_min": processed_item[3],
                "valor_max": processed_item[4],
                "valor_promedio": processed_item[5],
                "valores_texto": processed_item[6],
                "total_mediciones": processed_item[7]
            })
        
        # Calcular estadísticas basadas en los analitos disponibles
        bmi_data = [item for item in processed_data if item["analito"] == "bmi" and item["valor_promedio"]]
        colesterol_alto_data = [item for item in processed_data if item["analito"] == "colesterol alto"]
        problemas_corazon_data = [item for item in processed_data if item["analito"] == "problemas_corazon"]
        acv_data = [item for item in processed_data if item["analito"] == "acv"]
        
        # Estadísticas de presión arterial
        presion_arterial_data = [item for item in processed_data if item["analito"] == "presión arterial"]
        presion_normal_count = len([item for item in presion_arterial_data if item["valores_texto"] == "Normal"])
        presion_alta_count = len([item for item in presion_arterial_data if item["valores_texto"] == "Alta"])
        hipertension_count = len([item for item in presion_arterial_data if item["valores_texto"] == "Hypertension"])
        prehipertension_count = len([item for item in presion_arterial_data if item["valores_texto"] == "Prehypertension"])
        
        # Calcular BMI promedio
        bmi_promedio = 0
        if bmi_data:
            bmi_values = []
            for item in bmi_data:
                if item["valor_promedio"]:
                    try:
                        # Convertir a float si es string
                        valor = float(item["valor_promedio"]) if isinstance(item["valor_promedio"], str) else item["valor_promedio"]
                        if isinstance(valor, (int, float)):
                            bmi_values.append(valor)
                    except (ValueError, TypeError):
                        continue
            bmi_promedio = round(sum(bmi_values) / len(bmi_values), 2) if bmi_values else 0
        
        stats = {
            "totalRegistros": len(processed_data),
            "bmiPromedio": bmi_promedio,
            "colesterolAltoCount": len(colesterol_alto_data),
            "problemasCorazonCount": len(problemas_corazon_data),
            "acvCount": len(acv_data),
            "presionNormalCount": presion_normal_count,
            "presionAltaCount": presion_alta_count,
            "hipertensionCount": hipertension_count,
            "prehipertensionCount": prehipertension_count,
            "totalAnalitos": len(set(item["analito"] for item in processed_data))
        }
        
        return jsonify({
            "success": True,
            "dashboard": "lab-stats",
            "stats": stats
        })
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/dashboard/lab/charts", methods=["GET"])
@auth_required
def get_dashboard_lab_charts():
    """Dashboard: Gráficos de Laboratorio con procesamiento optimizado"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        cur.execute("BEGIN;")
        cur.execute("CALL sp_dashboard_lab('cursor_result');")
        cur.execute("FETCH ALL FROM cursor_result;")
        data = cur.fetchall()
        cur.execute("COMMIT;")
        
        if not data:
            return jsonify({
                "success": True,
                "dashboard": "lab-charts",
                "lineData": {"labels": [], "datasets": []},
                "barData": {"labels": [], "datasets": []},
                "processedData": []
            })
        
        # Procesar datos como objetos
        processed_data = []
        for item in data:
            # Asegurar que cada elemento sea serializable, manteniendo tipos numéricos
            processed_item = []
            for i in range(len(item)):
                if item[i] is None:
                    processed_item.append(None)
                elif isinstance(item[i], (int, float, bool)):
                    processed_item.append(item[i])
                elif isinstance(item[i], str):
                    processed_item.append(item[i])
                else:
                    # Convertir a string solo si no es un tipo básico
                    processed_item.append(str(item[i]))
            
            processed_data.append({
                "id_usuario": processed_item[0],
                "fecha": processed_item[1],
                "analito": processed_item[2],
                "valor_min": processed_item[3],
                "valor_max": processed_item[4],
                "valor_promedio": processed_item[5],
                "valores_texto": processed_item[6],
                "total_mediciones": processed_item[7]
            })
        
        # Retornar datos procesados para que el frontend haga los cálculos
        return jsonify({
            "success": True,
            "dashboard": "lab-charts",
            "processedData": processed_data,
            "total": len(processed_data)
        })
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/dashboard/estilo-vida", methods=["GET"])
@auth_required
def get_dashboard_estilo_vida():
    """Dashboard 4: Estilo de Vida"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Usar transacción para manejar el cursor
        cur.execute("BEGIN;")
        cur.execute("CALL sp_dashboard_estilo_vida('cursor_result');")
        cur.execute("FETCH ALL FROM cursor_result;")
        data = cur.fetchall()
        cur.execute("COMMIT;")
        
        # Procesar datos para que sean serializables
        processed_data = []
        for row in data:
            processed_data.append(list(row))
        
        return jsonify({
            "success": True,
            "dashboard": "estilo-vida",
            "data": processed_data,
            "total": len(processed_data)
        })
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/dashboard/predicciones", methods=["GET"])
@auth_required
def get_dashboard_predicciones():
    """Dashboard 5: Predicciones"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Usar transacción para manejar el cursor
        cur.execute("BEGIN;")
        cur.execute("CALL sp_dashboard_predicciones('cursor_result');")
        cur.execute("FETCH ALL FROM cursor_result;")
        data = cur.fetchall()
        cur.execute("COMMIT;")
        
        # Procesar datos para que sean serializables
        processed_data = []
        for row in data:
            processed_data.append(list(row))
        
        return jsonify({
            "success": True,
            "dashboard": "predicciones",
            "data": processed_data,
            "total": len(processed_data)
        })
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/dashboard/medicacion", methods=["GET"])
@auth_required
def get_dashboard_medicacion():
    """Dashboard 6: Medicación"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Usar transacción para manejar el cursor
        cur.execute("BEGIN;")
        cur.execute("CALL sp_dashboard_medicacion('cursor_result');")
        cur.execute("FETCH ALL FROM cursor_result;")
        data = cur.fetchall()
        cur.execute("COMMIT;")
        
        # Procesar datos para que sean serializables
        processed_data = []
        for row in data:
            processed_data.append(list(row))
        
        return jsonify({
            "success": True,
            "dashboard": "medicacion",
            "data": processed_data,
            "total": len(processed_data)
        })
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/dashboard/documentos", methods=["GET"])
@auth_required
def get_dashboard_documentos():
    """Dashboard 7: Documentos"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Usar transacción para manejar el cursor
        cur.execute("BEGIN;")
        cur.execute("CALL sp_dashboard_documentos('cursor_result');")
        cur.execute("FETCH ALL FROM cursor_result;")
        data = cur.fetchall()
        cur.execute("COMMIT;")
        
        # Procesar datos para que sean serializables
        processed_data = []
        for row in data:
            processed_data.append(list(row))
        
        return jsonify({
            "success": True,
            "dashboard": "documentos",
            "data": processed_data,
            "total": len(processed_data)
        })
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/dashboard/auditoria", methods=["GET"])
@auth_required
def get_dashboard_auditoria():
    """Dashboard 8: Auditoría"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Usar transacción para manejar el cursor
        cur.execute("BEGIN;")
        cur.execute("CALL sp_dashboard_auditoria('cursor_result');")
        cur.execute("FETCH ALL FROM cursor_result;")
        data = cur.fetchall()
        cur.execute("COMMIT;")
        
        # Procesar datos para que sean serializables
        processed_data = []
        for row in data:
            processed_data.append(list(row))
        
        return jsonify({
            "success": True,
            "dashboard": "auditoria",
            "data": processed_data,
            "total": len(processed_data)
        })
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/dashboard/monitoreo-pa-charts", methods=["GET"])
@auth_required
def get_dashboard_monitoreo_pa_charts():
    """Dashboard: Gráficos de Monitoreo PA con procesamiento optimizado"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        cur.execute("BEGIN;")
        cur.execute("CALL sp_dashboard_monitoreo_pa('cursor_result');")
        cur.execute("FETCH ALL FROM cursor_result;")
        data = cur.fetchall()
        cur.execute("COMMIT;")
        
        if not data:
            return jsonify({
                "success": True,
                "dashboard": "monitoreo-pa-charts",
                "lineData": {"labels": [], "datasets": []},
                "barData": {"labels": [], "datasets": []},
                "processedData": []
            }, "dashboard_monitoreo_pa_charts")
        
        # Procesar datos como objetos
        processed_data = []
        for item in data:
            processed_data.append({
                "id_usuario": item[0],
                "fecha": item[1],
                "id_postura": item[2],
                "id_dispositivo": item[3],
                "bp_sistolica_promedio": item[4],
                "bp_sistolica_min": item[5],
                "bp_sistolica_max": item[6],
                "bp_diastolica_promedio": item[7],
                "bp_diastolica_min": item[8],
                "bp_diastolica_max": item[9]
            })
        
        # Retornar datos procesados para que el frontend haga los cálculos
        return jsonify({
            "success": True,
            "dashboard": "monitoreo-pa-charts",
            "processedData": processed_data,
            "total": len(processed_data)
        })
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    except Exception as e:
        return jsonify({"error": f"processing_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/dashboard/completo", methods=["GET"])
@auth_required
def get_dashboard_completo():
    """Dashboard 9: Dashboard Completo"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        cur.execute("BEGIN;")
        cur.execute("CALL sp_dashboard_completo('cursor_result');")
        cur.execute("FETCH ALL FROM cursor_result;")
        data = cur.fetchall()
        cur.execute("COMMIT;")
        
        return jsonify({
            "success": True,
            "dashboard": "completo",
            "data": data,
            "total": len(data)
        }, "dashboard_completo")
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


@app.route("/api/dashboard/signos-vitales-stats", methods=["GET"])
@auth_required
def get_dashboard_signos_vitales_stats():
    """Dashboard: Estadísticas de Signos Vitales"""
    conn = None
    cur = None
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        
        # Usar transacción para manejar el cursor
        cur.execute("BEGIN;")
        cur.execute("CALL sp_dashboard_signos_vitales('cursor_result');")
        cur.execute("FETCH ALL FROM cursor_result;")
        data = cur.fetchall()
        cur.execute("COMMIT;")
        
        # Procesar datos para calcular estadísticas
        if not data:
            return jsonify({
                "success": True,
                "dashboard": "signos-vitales-stats",
                "stats": {
                    "totalRegistros": 0,
                    "frecuenciaCardiacaPromedio": 0,
                    "saturacionOxigenoPromedio": 0,
                    "frecuenciaCardiacaMin": 0,
                    "frecuenciaCardiacaMax": 0,
                    "saturacionOxigenoMin": 0,
                    "saturacionOxigenoMax": 0
                }
            }, "dashboard_signos_vitales_stats")
        
        # Convertir datos a objetos con propiedades nombradas
        processed_data = []
        for item in data:
            processed_data.append({
                "id_usuario": item[0],
                "fecha": item[1],
                "id_postura": item[2],
                "frecuencia_cardiaca_promedio": item[3],
                "saturacion_oxigeno_promedio": item[4]
            })
        
        # Calcular estadísticas
        all_fc = [item["frecuencia_cardiaca_promedio"] for item in processed_data if item["frecuencia_cardiaca_promedio"]]
        all_spo2 = [item["saturacion_oxigeno_promedio"] for item in processed_data if item["saturacion_oxigeno_promedio"]]
        
        stats = {
            "totalRegistros": len(processed_data),
            "frecuenciaCardiacaPromedio": round(sum(all_fc) / len(all_fc), 1) if all_fc else 0,
            "saturacionOxigenoPromedio": round(sum(all_spo2) / len(all_spo2), 1) if all_spo2 else 0,
            "frecuenciaCardiacaMin": round(min(all_fc), 1) if all_fc else 0,
            "frecuenciaCardiacaMax": round(max(all_fc), 1) if all_fc else 0,
            "saturacionOxigenoMin": round(min(all_spo2), 1) if all_spo2 else 0,
            "saturacionOxigenoMax": round(max(all_spo2), 1) if all_spo2 else 0
        }
        
        return jsonify({
            "success": True,
            "dashboard": "signos-vitales-stats",
            "stats": stats
        }, "dashboard_signos_vitales_stats")
        
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        return jsonify({"error": f"db_error: {str(e)}"}), 500
    except Exception as e:
        return jsonify({"error": f"processing_error: {str(e)}"}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            put_db_conn(conn)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5001)
