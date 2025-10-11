import { useState, useEffect } from "react";
import entityService from '../services/entityService';
import RetryButton from './RetryButton';
import LoadingSpinner from './LoadingSpinner';
import ErrorDisplay from './ErrorDisplay';
import '../styles.css';

export default function DatabaseTables() {
  const [entidades, setEntidades] = useState([]);
  const [selectedTable, setSelectedTable] = useState("");
  const [tableData, setTableData] = useState([]);
  const [tableColumns, setTableColumns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [dataLoading, setDataLoading] = useState(false);
  const [error, setError] = useState(null);
  
  // Estados para el formulario inline
  const [newRecord, setNewRecord] = useState({});
  const [isCreating, setIsCreating] = useState(false);

  // Estados para edición inline
  const [editingRowIndex, setEditingRowIndex] = useState(null);
  const [editedRow, setEditedRow] = useState({});
  const [pkColumns, setPkColumns] = useState([]);

  // Cargar entidades al montar el componente
  useEffect(() => {
    const loadEntidades = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await entityService.getEntidades();
        
        if (response.success && response.entidades) {
          // Transformar las entidades para el formato esperado
          const transformedEntidades = response.entidades.map(entidad => ({
            name: entidad.nombre.toLowerCase(),
            label: entidad.nombre,
            description: `Tabla de ${entidad.nombre}`,
            id: entidad.id
          }));
          
          setEntidades(transformedEntidades);
          
          // Seleccionar la primera entidad por defecto
          if (transformedEntidades.length > 0) {
            setSelectedTable(transformedEntidades[0].name);
          }
        }
      } catch (err) {
        console.error('Error loading entities:', err);
        // Si es un error de autenticación, redirigir al login
        if (err.message.includes('Sesión expirada') || err.message.includes('No authentication token')) {
          localStorage.removeItem('token');
          localStorage.removeItem('user');
          window.location.reload();
        }
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    loadEntidades();
  }, []);

  // Cargar datos de la tabla seleccionada
  // Función para cargar datos de la tabla
  const loadTableData = async () => {
    try {
      setDataLoading(true);
      const response = await entityService.getEntidadData(selectedTable);
      
      if (response.success) {
        // Los datos vienen como array de arrays, usar las columnas del backend
        const datos = response.datos || [];
        const columnas = response.columnas || [];
        
        setTableColumns(columnas);
        setTableData(datos);
      }
    } catch (err) {
      console.error('Error loading table data:', err);
      // Si es un error de autenticación, redirigir al login
      if (err.message.includes('Sesión expirada') || err.message.includes('No authentication token')) {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        window.location.reload();
      }
      setTableData([]);
      setTableColumns([]);
    } finally {
      setDataLoading(false);
    }
  };

  useEffect(() => {
    if (selectedTable) {
      loadTableData();
    }
  }, [selectedTable]);


  const currentTableInfo = entidades.find(table => table.name === selectedTable);

  // Función para inicializar el nuevo registro
  const initializeNewRecord = () => {
    const initialRecord = {};
    tableColumns.forEach(column => {
      initialRecord[column] = '';
    });
    setNewRecord(initialRecord);
  };

  // Función para manejar cambios en los inputs
  const handleInputChange = (column, value) => {
    setNewRecord(prev => ({
      ...prev,
      [column]: value
    }));
  };

  // Función para crear el registro
  const handleCreateRecord = async () => {
    setIsCreating(true);
    try {
      // Verificar que hay datos para enviar
      const hasData = Object.values(newRecord).some(value => value && value.trim() !== '');
      if (!hasData) {
        alert('Por favor, ingresa al menos un valor antes de agregar el registro');
        return;
      }

      // Llamar al endpoint correspondiente usando el nombre real de la tabla
      const response = await entityService.createEntidadRecord(currentTableInfo?.label, newRecord);
      
      if (response.success) {
        // Limpiar formulario
        initializeNewRecord();
        
        // Recargar datos de la tabla
        await loadTableData();
        
        alert('Acción realizada con éxito');
      } else {
        alert('No se pudo realizar la acción. Intenta más tarde.');
      }
      
    } catch (err) {
      console.error('Error al crear registro:', err);
      alert(err?.message || 'No se pudo realizar la acción. Intenta más tarde.');
    } finally {
      setIsCreating(false);
    }
  };

  // Eliminar registro: soporta PK simple y compuesta automáticamente
  const handleDeleteRecord = async (row) => {
    try {
      const confirmed = window.confirm('¿Eliminar este registro? Esta acción no se puede deshacer.');
      if (!confirmed) return;

      const response = await entityService.deleteEntidadRecord(
        currentTableInfo?.label,
        row,
        tableColumns
      );
      if (response.success) {
        await loadTableData();
      } else {
        alert('No se pudo eliminar el registro.');
      }
    } catch (err) {
      console.error('Error al eliminar registro:', err);
      alert(err?.message || 'No se pudo eliminar el registro.');
    }
  };

  // Entrar a modo edición para una fila
  const handleEditRecord = async (rowIndex) => {
    const row = tableData[rowIndex];
    const rowObj = {};
    tableColumns.forEach((col, i) => {
      rowObj[col] = row[i];
    });
    try {
      // Obtener columnas PK para deshabilitar edición y validación
      const info = await entityService.getPkColumns(currentTableInfo?.label || currentTableInfo?.name);
      setPkColumns(info.pkColumns || []);
    } catch (e) {
      setPkColumns([]);
    }
    setEditingRowIndex(rowIndex);
    setEditedRow(rowObj);
  };

  // Cambiar valor durante edición
  const handleEditChange = (column, value) => {
    setEditedRow(prev => ({
      ...prev,
      [column]: value
    }));
  };

  // Cancelar edición
  const handleCancelEdit = () => {
    setEditingRowIndex(null);
    setEditedRow({});
  };

  // Guardar edición
  const handleSaveEdit = async (rowIndex) => {
    try {
      const originalRow = tableData[rowIndex];
      // Validar que las PK no estén vacías
      for (const pk of pkColumns) {
        const idx = tableColumns.indexOf(pk);
        const val = Array.isArray(originalRow) ? originalRow[idx] : originalRow?.[pk];
        if (val === '' || val === null || typeof val === 'undefined') {
          alert('La clave primaria no puede estar vacía.');
          return;
        }
      }
      const resp = await entityService.updateEntidadRecord(
        currentTableInfo?.label || currentTableInfo?.name,
        tableColumns,
        originalRow,
        editedRow
      );
      if (resp.success) {
        // Actualización optimista: mantener posición y solo reemplazar valores editados
        setTableData(prev => {
          const next = [...prev];
          const updatedRow = tableColumns.map((col, i) => {
            // Nunca sobrescribir columnas PK en UI
            if (pkColumns.includes(col)) return next[rowIndex][i];
            return editedRow.hasOwnProperty(col) ? editedRow[col] : next[rowIndex][i];
          });
          next[rowIndex] = updatedRow;
          return next;
        });
        handleCancelEdit();
      } else {
        alert('No se pudo actualizar el registro.');
      }
    } catch (err) {
      console.error('Error al actualizar registro:', err);
      alert(err?.message || 'No se pudo actualizar el registro.');
    }
  };

  // Inicializar nuevo registro cuando cambien las columnas
  useEffect(() => {
    if (tableColumns.length > 0) {
      initializeNewRecord();
    }
  }, [tableColumns]);

  // Mostrar estado de carga
  if (loading) {
    return (
      <div className="database-tables">
        <div className="dashboard-header">
          <h1>Gestión de Base de Datos</h1>
        </div>
        <LoadingSpinner 
          message="Cargando entidades de la base de datos..."
          variant="dots"
          size="large"
        />
      </div>
    );
  }

  // Mostrar estado de error
  if (error) {
    return (
      <div className="database-tables">
        <div className="dashboard-header">
          <h1>Gestión de Base de Datos</h1>
        </div>
        <ErrorDisplay
          title="Error al cargar las entidades"
          message={error}
          type="network"
          onRetry={() => window.location.reload()}
          showRetry={true}
        />
      </div>
    );
  }

  return (
    <div className="database-tables">
      <div className="dashboard-header">
        <h1>Gestión de Base de Datos</h1>
        <div className="table-selector">
          <label htmlFor="table-select">Seleccionar tabla:</label>
          <select 
            id="table-select"
            value={selectedTable} 
            onChange={(e) => setSelectedTable(e.target.value)}
            className="table-dropdown"
          >
            {entidades.map(table => (
              <option key={table.name} value={table.name}>
                {table.label}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="table-info-card">
        <h3>{currentTableInfo?.label}</h3>
        <p>{currentTableInfo?.description}</p>
        <p><strong>Registros:</strong> {tableData.length}</p>
      </div>

      <div className="table-container">
        <div className="table-card">
          <h4>Datos de la tabla: {currentTableInfo?.label}</h4>
          {dataLoading ? (
            <div className="loading-spinner">
              <p>Cargando datos de la tabla...</p>
            </div>
          ) : (
            <div className="table-wrapper">
              <table className="data-table">
                <thead>
                  <tr>
                    {tableColumns.map(column => (
                      <th key={column}>{column}</th>
                    ))}
                    <th className="action-header">Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  {/* Fila para crear nuevo registro - siempre al principio */}
                  <tr className="new-record-row">
                    {tableColumns.map((column, index) => (
                      <td key={index}>
                        <input
                          type="text"
                          value={newRecord[column] || ''}
                          onChange={(e) => handleInputChange(column, e.target.value)}
                          placeholder={`Agregar ${column}`}
                          disabled={isCreating}
                          className="new-record-input"
                        />
                      </td>
                    ))}
                    <td className="action-cell">
                      <button 
                        className="add-record-button"
                        onClick={handleCreateRecord}
                        disabled={isCreating}
                        title="Agregar registro"
                      >
                        {isCreating ? '...' : '+'}
                      </button>
                    </td>
                  </tr>
                  
                  {/* Datos existentes */}
                  {tableData.map((row, index) => (
                    <tr key={index}>
                      {tableColumns.map((column, cellIndex) => (
                        <td key={cellIndex}>
                          {editingRowIndex === index ? (
                            pkColumns.includes(column) ? (
                              // Mostrar PK como texto normal (no editable)
                              (() => {
                                const cell = row[cellIndex];
                                if (typeof cell === 'boolean') {
                                  return cell ? 'Sí' : 'No';
                                } else if (cell === null) {
                                  return 'NULL';
                                } else if (typeof cell === 'object') {
                                  return <pre className="json-display">{JSON.stringify(cell, null, 2)}</pre>;
                                } else {
                                  return cell;
                                }
                              })()
                            ) : (
                              <input
                                type="text"
                                value={editedRow[column] ?? ''}
                                onChange={(e) => handleEditChange(column, e.target.value)}
                                className="edit-record-input"
                              />
                            )
                          ) : (
                            (() => {
                              const cell = row[cellIndex];
                              if (typeof cell === 'boolean') {
                                return cell ? 'Sí' : 'No';
                              } else if (cell === null) {
                                return 'NULL';
                              } else if (typeof cell === 'object') {
                                return <pre className="json-display">{JSON.stringify(cell, null, 2)}</pre>;
                              } else {
                                return cell;
                              }
                            })()
                          )}
                        </td>
                      ))}
                      <td className="action-cell">
                        {editingRowIndex === index ? (
                          <>
                            <button
                              className="save-record-button"
                              onClick={() => handleSaveEdit(index)}
                              title="Guardar cambios"
                            >
                              ✓
                            </button>
                            <button
                              className="cancel-edit-button"
                              onClick={handleCancelEdit}
                              title="Cancelar"
                            >
                              ×
                            </button>
                          </>
                        ) : (
                          <>
                            <button
                              className="edit-record-button"
                              onClick={() => handleEditRecord(index)}
                              title="Editar registro"
                            >
                              ✎
                            </button>
                            <button 
                              className="delete-record-button"
                              onClick={() => handleDeleteRecord(row)}
                              title="Eliminar registro"
                            >
                              -
                            </button>
                          </>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
              
              {/* Mensaje de no datos - aparece debajo de la tabla cuando no hay registros */}
              {tableData.length === 0 && (
                <div className="no-data">
                  <p>No hay datos disponibles para esta tabla</p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
