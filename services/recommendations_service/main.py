import os
from fastapi import FastAPI, HTTPException, Depends, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from services.shared.db import get_conn
from services.shared.auth import require_auth
import traceback
from dicttoxml import dicttoxml

app = FastAPI(title="Recommendations Service", version="1.0")
APP_PORT = int(os.getenv("RECOMMENDATIONS_SERVICE_PORT", "8011"))

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["Authorization", "Content-Type"],
)


@app.get("/recommendations/{user_id}")
def get_recommendations(user_id: int, user: dict = Depends(require_auth), request: Request = None):
    """Get personalized health recommendations based on user's latest predictions. Requires valid JWT token."""
    # Verify the user is accessing their own data or is an admin
    if str(user_id) != user["sub"] and user.get("roleId") != 1:
        raise HTTPException(status_code=403, detail="Access denied: Cannot access other users' data")
    
    print(f"=== GET RECOMMENDATIONS FOR USER {user_id} ===")
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                # Step 1: Get the latest predictions for diabetes (id_enfermedad=1) and hypertension (id_enfermedad=2)
                cur.execute("""
                    SELECT DISTINCT ON (id_enfermedad)
                        id_enfermedad, prediccion, fecha
                    FROM Prediccion
                    WHERE id_usuario = %s AND id_enfermedad IN (1, 2)
                    ORDER BY id_enfermedad, fecha DESC
                """, (user_id,))
                
                prediction_rows = cur.fetchall()
                
                # Build a map of id_enfermedad -> prediccion (boolean)
                has_diabetes = False
                has_hypertension = False
                
                for row in prediction_rows:
                    id_enf = row['id_enfermedad']
                    prediccion = row['prediccion']
                    print(f"DEBUG: Found prediction for id_enfermedad={id_enf}, prediccion={prediccion}")
                    
                    if id_enf == 1:
                        has_diabetes = bool(prediccion)
                    elif id_enf == 2:
                        has_hypertension = bool(prediccion)
                
                print(f"DEBUG: has_diabetes={has_diabetes}, has_hypertension={has_hypertension}")
                
                # Step 2: Collect all applicable condition IDs
                applicable_conditions = []
                if has_diabetes:
                    applicable_conditions.append(1)
                if has_hypertension:
                    applicable_conditions.append(2)
                
                print(f"DEBUG: Applicable conditions: {applicable_conditions}")
                
                # Step 3: Query for recommendations for those conditions
                recommendations = []
                
                if applicable_conditions:
                    # Use DISTINCT ON to avoid duplicate recommendations if they apply to multiple conditions
                    placeholders = ','.join(['%s'] * len(applicable_conditions))
                    cur.execute(f"""
                        SELECT DISTINCT ON (r.id_recomendacion)
                            r.id_recomendacion, r.titulo, r.descripcion, er.id_enfermedad
                        FROM Enfermedad_Recomendacion er
                        JOIN Recomendacion r ON er.id_recomendacion = r.id_recomendacion
                        WHERE er.id_enfermedad IN ({placeholders})
                        ORDER BY r.id_recomendacion, er.id_enfermedad
                    """, applicable_conditions)
                    
                    recommendation_rows = cur.fetchall()
                    print(f"DEBUG: Found {len(recommendation_rows)} recommendations")
                    
                    for rec in recommendation_rows:
                        # Fix double-encoded UTF-8: if the text was stored with encoding issues,
                        # try to decode and re-encode properly
                        titulo = rec['titulo']
                        descripcion = rec['descripcion']
                        
                        # Attempt to fix double-encoded UTF-8
                        try:
                            if titulo and isinstance(titulo, str):
                                titulo_bytes = titulo.encode('iso-8859-1')
                                titulo = titulo_bytes.decode('utf-8')
                        except Exception as e:
                            pass  # Keep original if decode fails
                        
                        try:
                            if descripcion and isinstance(descripcion, str):
                                desc_bytes = descripcion.encode('iso-8859-1')
                                descripcion = desc_bytes.decode('utf-8')
                        except Exception as e:
                            pass  # Keep original if decode fails
                        
                        recommendations.append({
                            "id_recomendacion": rec['id_recomendacion'],
                            "titulo": titulo,
                            "descripcion": descripcion,
                            "id_enfermedad": rec['id_enfermedad']
                        })
                
                print(f"=== RETURNING {len(recommendations)} RECOMMENDATIONS ===")
                
                return {
                    "user_id": user_id,
                    "has_diabetes": has_diabetes,
                    "has_hypertension": has_hypertension,
                    "recommendations": recommendations
                }
    
    except Exception as e:
        error_trace = traceback.format_exc()
        print(f"ERROR in get_recommendations: {error_trace}")
        raise HTTPException(status_code=500, detail=f"Error retrieving recommendations: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=APP_PORT)



