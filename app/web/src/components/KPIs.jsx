import { useState, useEffect } from 'react';
import { Pie, Line, Bar } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  ArcElement,
  Tooltip,
  Legend,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title
} from 'chart.js';
import '../styles.css';

ChartJS.register(ArcElement, Tooltip, Legend, CategoryScale, LinearScale, PointElement, LineElement, BarElement, Title);

const API_BASE_URL = 'http://localhost:5001/api';

// Colores para el gráfico de pie (siguiendo los colores de reportes)
const COLORS = ['#4ECDC4', '#96CEB4', '#45B7D1', '#FF6B6B'];

// Badge para días de actividad
function ActividadBadge({ dias }) {
  let color = '#5B696F';
  let textColor = '#FFFFFF';
  
  if (dias >= 7) {
    color = '#4CAF50'; // Verde (como "Normal" en signos vitales)
  } else if (dias >= 3) {
    color = '#FFD93D'; // Amarillo (como "Moderado" en presión arterial)
    textColor = '#000000';
  } else if (dias > 0) {
    color = '#FF6B6B'; // Rojo coral (como "Alto riesgo" en presión arterial)
  }
  
  return (
    <span style={{
      backgroundColor: color,
      color: textColor,
      padding: "2px 6px",
      borderRadius: "4px",
      marginLeft: "8px",
      fontSize: "0.8rem"
    }}>
      {dias} días
    </span>
  );
}

export default function KPIs() {
  const [activeSection, setActiveSection] = useState('dashboard-kpis');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [kpisData, setKpisData] = useState(null);
  const [usuariosPorRolData, setUsuariosPorRolData] = useState(null);
  const [frecuenciaDiariaData, setFrecuenciaDiariaData] = useState(null);
  const [crecimientoSemanalData, setCrecimientoSemanalData] = useState(null);
  const [actividadUsuariosData, setActividadUsuariosData] = useState(null);
  const [resumenEjecutivoData, setResumenEjecutivoData] = useState(null);

  // Función para obtener datos de KPIs
  const fetchKPIsData = async () => {
    setLoading(true);
    setError(null);
    try {
      const token = localStorage.getItem('token');
      
      if (!token) {
        throw new Error('No hay token de autenticación. Por favor, inicia sesión.');
      }

      const response = await fetch(`${API_BASE_URL}/dashboard/kpis`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('Response error:', response.status, errorText);
        throw new Error(`Error ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      console.log('KPIs data received:', data);
      
      if (data.success) {
        setKpisData(data.data);
      } else {
        throw new Error(data.error || 'Error al obtener datos de KPIs');
      }
    } catch (err) {
      setError(err.message);
      console.error('Error fetching KPIs data:', err);
    } finally {
      setLoading(false);
    }
  };

  // Función para obtener datos de usuarios por rol
  const fetchUsuariosPorRolData = async () => {
    setLoading(true);
    setError(null);
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        throw new Error('No hay token de autenticación. Por favor, inicia sesión.');
      }
      const response = await fetch(`${API_BASE_URL}/dashboard/kpis/usuarios-por-rol`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('Response error:', response.status, errorText);
        throw new Error(`Error ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      console.log('Usuarios por rol data received:', data);

      if (data.success) {
        setUsuariosPorRolData(data.data);
      } else {
        throw new Error(data.error || 'Error al obtener datos de usuarios por rol');
      }
    } catch (err) {
      setError(err.message);
      console.error('Error fetching usuarios por rol data:', err);
    } finally {
      setLoading(false);
    }
  };

  // Función para obtener datos de frecuencia diaria
  const fetchFrecuenciaDiariaData = async () => {
    setLoading(true);
    setError(null);
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        throw new Error('No hay token de autenticación. Por favor, inicia sesión.');
      }
      const response = await fetch(`${API_BASE_URL}/dashboard/kpis/frecuencia-diaria`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('Response error:', response.status, errorText);
        throw new Error(`Error ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      console.log('Frecuencia diaria data received:', data);

      if (data.success) {
        setFrecuenciaDiariaData(data.data);
      } else {
        throw new Error(data.error || 'Error al obtener datos de frecuencia diaria');
      }
    } catch (err) {
      setError(err.message);
      console.error('Error fetching frecuencia diaria data:', err);
    } finally {
      setLoading(false);
    }
  };

  // Función para obtener datos de crecimiento semanal
  const fetchCrecimientoSemanalData = async () => {
    setLoading(true);
    setError(null);
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        throw new Error('No hay token de autenticación. Por favor, inicia sesión.');
      }
      const response = await fetch(`${API_BASE_URL}/dashboard/kpis/crecimiento-semanal`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('Response error:', response.status, errorText);
        throw new Error(`Error ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      console.log('Crecimiento semanal data received:', data);

      if (data.success) {
        setCrecimientoSemanalData(data.data);
      } else {
        throw new Error(data.error || 'Error al obtener datos de crecimiento semanal');
      }
    } catch (err) {
      setError(err.message);
      console.error('Error fetching crecimiento semanal data:', err);
    } finally {
      setLoading(false);
    }
  };

  // Función para obtener datos de actividad de usuarios
  const fetchActividadUsuariosData = async () => {
    setLoading(true);
    setError(null);
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        throw new Error('No hay token de autenticación. Por favor, inicia sesión.');
      }
      const response = await fetch(`${API_BASE_URL}/dashboard/kpis/actividad-usuarios`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('Response error:', response.status, errorText);
        throw new Error(`Error ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      console.log('Actividad usuarios data received:', data);

      if (data.success) {
        setActividadUsuariosData(data.data);
      } else {
        throw new Error(data.error || 'Error al obtener datos de actividad de usuarios');
      }
    } catch (err) {
      setError(err.message);
      console.error('Error fetching actividad usuarios data:', err);
    } finally {
      setLoading(false);
    }
  };

  // Función para obtener datos de resumen ejecutivo
  const fetchResumenEjecutivoData = async () => {
    setLoading(true);
    setError(null);
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        throw new Error('No hay token de autenticación. Por favor, inicia sesión.');
      }
      const response = await fetch(`${API_BASE_URL}/dashboard/kpis/resumen-ejecutivo`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('Response error:', response.status, errorText);
        throw new Error(`Error ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      console.log('Resumen ejecutivo data received:', data);

      if (data.success) {
        setResumenEjecutivoData(data.data);
      } else {
        throw new Error(data.error || 'Error al obtener datos de resumen ejecutivo');
      }
    } catch (err) {
      setError(err.message);
      console.error('Error fetching resumen ejecutivo data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (activeSection === 'dashboard-kpis') {
      fetchKPIsData();
    } else if (activeSection === 'usuarios-por-rol') {
      fetchUsuariosPorRolData();
    } else if (activeSection === 'frecuencia-diaria') {
      fetchFrecuenciaDiariaData();
    } else if (activeSection === 'crecimiento-semanal') {
      fetchCrecimientoSemanalData();
    } else if (activeSection === 'actividad-usuarios') {
      fetchActividadUsuariosData();
    } else if (activeSection === 'resumen-ejecutivo') {
      fetchResumenEjecutivoData();
    }
  }, [activeSection]);

  if (loading) {
    return (
      <div className="admin-dashboard">
        <div className="loading-container">
          <h2>Cargando datos de KPIs...</h2>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="admin-dashboard">
        <div className="error-container">
          <h2>Error al cargar los datos</h2>
          <p>{error}</p>
          <button onClick={fetchKPIsData}>Reintentar</button>
        </div>
      </div>
    );
  }

  return (
    <div className="admin-dashboard">
      <div className="dashboard-header">
        <h1>Indicadores Clave de Rendimiento (KPIs)</h1>
        <div className="section-selector">
          <label htmlFor="sectionSelect">Sección:</label>
          <select 
            id="sectionSelect" 
            value={activeSection} 
            onChange={(e) => setActiveSection(e.target.value)}
            style={{ marginLeft: '10px', padding: '5px 10px' }}
          >
                    <option value="dashboard-kpis">Indicadores Principales</option>
            <option value="usuarios-por-rol">Usuarios por Rol</option>
            <option value="frecuencia-diaria">Frecuencia Diaria</option>
            <option value="crecimiento-semanal">Crecimiento Semanal</option>
            <option value="actividad-usuarios">Actividad de Usuarios</option>
            <option value="resumen-ejecutivo">Resumen Ejecutivo</option>
          </select>
        </div>
      </div>

      {activeSection === 'dashboard-kpis' && kpisData && (
        <>
          <h4 style={{ margin: '0 0 15px 0', color: '#ADC7EA', fontSize: '1.2rem' }}>Indicadores Principales</h4>
          
          <div>
          
          {/* Contenedor 1: Contenidos Publicados */}
          <div className="table-card" style={{ marginBottom: '20px' }}>
            <div style={{ marginBottom: '20px', padding: '15px', backgroundColor: '#1E2B38', borderRadius: '8px', border: '1px solid #ADC7EA' }}>
              <h5 style={{ margin: '0 0 10px 0', color: '#ADC7EA' }}>Resumen de Contenidos Publicados</h5>
              <p style={{ margin: '0', fontSize: '14px', color: '#FFFFFF' }}>
                Total de documentos, predicciones, registros médicos, signos vitales y respuestas de estilo de vida en el sistema.
              </p>
            </div>
            
            <div className="overview-cards">
              <div className="kpi-card">
                <h4>Documentos Subidos</h4>
                <p>{kpisData.documentos_subidos}</p>
              </div>

              <div className="kpi-card">
                <h4>Predicciones Generadas</h4>
                <p>{kpisData.predicciones_generadas}</p>
              </div>

              <div className="kpi-card">
                <h4>Registros Médicos</h4>
                <p>{kpisData.registros_medicos}</p>
              </div>

              <div className="kpi-card">
                <h4>Signos Vitales</h4>
                <p>{kpisData.signos_vitales_registrados}</p>
              </div>

              <div className="kpi-card">
                <h4>Estilo de Vida</h4>
                <p>{kpisData.respuestas_estilo_vida}</p>
              </div>
            </div>
          </div>

          {/* Contenedor 2: Usuarios del Sistema */}
          <div className="table-card" style={{ marginBottom: '20px' }}>
            <div style={{ marginBottom: '20px', padding: '15px', backgroundColor: '#1E2B38', borderRadius: '8px', border: '1px solid #ADC7EA' }}>
              <h5 style={{ margin: '0 0 10px 0', color: '#ADC7EA' }}>Usuarios del Sistema</h5>
              <p style={{ margin: '0', fontSize: '14px', color: '#FFFFFF' }}>
                Total de usuarios registrados y actividad reciente (30 días, 7 días).
              </p>
            </div>

            <div className="overview-cards">
              <div className="kpi-card">
                <h4>Total Usuarios</h4>
                <p>{kpisData.total_usuarios}</p>
              </div>

              <div className="kpi-card">
                <h4>Usuarios Activos (30 días)</h4>
                <p>{kpisData.usuarios_activos_30_dias}</p>
              </div>

              <div className="kpi-card">
                <h4>Usuarios Activos (7 días)</h4>
                <p>{kpisData.usuarios_activos_7_dias}</p>
              </div>

              <div className="kpi-card">
                <h4>Usuarios Nuevos (30 días)</h4>
                <p>{kpisData.usuarios_nuevos_30_dias}</p>
              </div>
            </div>
          </div>

          {/* Contenedor 3: Actividad Reciente */}
          <div className="table-card">
            <div style={{ marginBottom: '20px', padding: '15px', backgroundColor: '#1E2B38', borderRadius: '8px', border: '1px solid #ADC7EA' }}>
              <h5 style={{ margin: '0 0 10px 0', color: '#ADC7EA' }}>Actividad Reciente (Últimos 7 días)</h5>
              <p style={{ margin: '0', fontSize: '14px', color: '#FFFFFF' }}>
                Nuevo contenido generado en la última semana.
              </p>
            </div>

            <div className="overview-cards">
              <div className="kpi-card">
                <h4>Documentos Esta Semana</h4>
                <p>{kpisData.documentos_esta_semana}</p>
              </div>

              <div className="kpi-card">
                <h4>Predicciones Esta Semana</h4>
                <p>{kpisData.predicciones_esta_semana}</p>
              </div>

              <div className="kpi-card">
                <h4>Registros Médicos Esta Semana</h4>
                <p>{kpisData.registros_medicos_esta_semana}</p>
              </div>

              <div className="kpi-card">
                <h4>Última Actualización</h4>
                <p>
                  {kpisData.fecha_actualizacion ? 
                    new Date(kpisData.fecha_actualizacion).toLocaleDateString() : 
                    'N/A'
                  }
                </p>
              </div>
            </div>
          </div>
          </div>
        </>
      )}

      {activeSection === 'usuarios-por-rol' && usuariosPorRolData && (
        <div className="table-card">
          <h4>Distribución de Usuarios por Rol</h4>
          
          <div style={{ marginBottom: '20px', padding: '15px', backgroundColor: '#1E2B38', borderRadius: '8px', border: '1px solid #ADC7EA' }}>
            <h5 style={{ margin: '0 0 10px 0', color: '#ADC7EA' }}>Distribución Porcentual</h5>
            <p style={{ margin: '0', fontSize: '14px', color: '#FFFFFF' }}>
              Visualización de la distribución de usuarios según su rol en el sistema.
            </p>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px', marginBottom: '20px' }}>
            {/* Gráfico de Pie */}
            <div style={{ 
              backgroundColor: '#1E2B38', 
              padding: '20px', 
              borderRadius: '8px', 
              border: '1px solid #ADC7EA'
            }}>
              <h5 style={{ margin: '0 0 15px 0', color: '#ADC7EA', textAlign: 'center' }}>
                Gráfico de Distribución
              </h5>
              <div style={{ height: '400px' }}>
                <Pie 
                  data={{
                    labels: usuariosPorRolData.map(rol => rol.rol),
                    datasets: [{
                      data: usuariosPorRolData.map(rol => rol.cantidad),
                      backgroundColor: COLORS,
                      borderColor: COLORS,
                      borderWidth: 2
                    }]
                  }}
                  options={{
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                      legend: { 
                        display: true, 
                        position: 'bottom',
                        labels: {
                          color: '#FFFFFF',
                          usePointStyle: true,
                          pointStyle: 'circle'
                        }
                      },
                      tooltip: {
                        callbacks: {
                          label: function(context) {
                            const rol = usuariosPorRolData[context.dataIndex];
                            return `${rol.rol}: ${rol.cantidad} usuarios (${rol.porcentaje}%)`;
                          }
                        }
                      }
                    }
                  }}
                />
              </div>
            </div>

            {/* Resumen de Datos */}
            <div style={{ 
              backgroundColor: '#1E2B38', 
              padding: '20px', 
              borderRadius: '8px', 
              border: '1px solid #ADC7EA'
            }}>
              <h5 style={{ margin: '0 0 15px 0', color: '#ADC7EA' }}>
                Resumen por Rol
              </h5>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                {usuariosPorRolData.map((rol, index) => (
                  <div key={index} style={{ 
                    display: 'flex', 
                    justifyContent: 'space-between', 
                    alignItems: 'center',
                    padding: '12px',
                    backgroundColor: '#2A3B4D',
                    borderRadius: '6px',
                    border: '1px solid #5B696F'
                  }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <div style={{ 
                        width: '12px', 
                        height: '12px', 
                        backgroundColor: COLORS[index % COLORS.length],
                        borderRadius: '50%'
                      }}></div>
                      <span style={{ color: '#FFFFFF', fontWeight: 'bold' }}>{rol.rol}</span>
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                      <span style={{ color: '#ADC7EA', fontWeight: 'bold' }}>{rol.cantidad}</span>
                      <span style={{ color: '#9DB3C1', fontSize: '0.9rem' }}>{rol.porcentaje}%</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}

      {activeSection === 'frecuencia-diaria' && frecuenciaDiariaData && (
        <div className="table-card">
          <h4>Frecuencia Diaria de Actualización</h4>
          
          <div style={{ marginBottom: '20px', padding: '15px', backgroundColor: '#1E2B38', borderRadius: '8px', border: '1px solid #ADC7EA' }}>
            <h5 style={{ margin: '0 0 10px 0', color: '#ADC7EA' }}>Actividad Diaria del Sistema</h5>
            <p style={{ margin: '0', fontSize: '14px', color: '#FFFFFF' }}>
              Frecuencia de creación de contenido por día en los últimos 30 días. Incluye documentos, predicciones y registros médicos.
            </p>
          </div>

          {/* Gráfico de Líneas */}
          <div style={{ 
            backgroundColor: '#1E2B38', 
            padding: '20px', 
            borderRadius: '8px', 
            border: '1px solid #ADC7EA',
            marginBottom: '20px'
          }}>
            <h5 style={{ margin: '0 0 15px 0', color: '#ADC7EA', textAlign: 'center' }}>
              Tendencia de Actividad Diaria
            </h5>
            <div style={{ height: '400px' }}>
              <Line 
                data={{
                  labels: [...new Set(frecuenciaDiariaData.map(item => 
                    new Date(item.fecha).toLocaleDateString()
                  ))].sort((a, b) => new Date(a) - new Date(b)),
                  datasets: [
                    {
                      label: 'Documentos',
                      data: frecuenciaDiariaData
                        .filter(item => item.tipo_contenido === 'documentos')
                        .map(item => item.cantidad),
                      borderColor: '#4ECDC4',
                      backgroundColor: '#4ECDC4',
                      tension: 0.1
                    },
                    {
                      label: 'Predicciones',
                      data: frecuenciaDiariaData
                        .filter(item => item.tipo_contenido === 'predicciones')
                        .map(item => item.cantidad),
                      borderColor: '#96CEB4',
                      backgroundColor: '#96CEB4',
                      tension: 0.1
                    },
                    {
                      label: 'Registros Médicos',
                      data: frecuenciaDiariaData
                        .filter(item => item.tipo_contenido === 'registros_medicos')
                        .map(item => item.cantidad),
                      borderColor: '#45B7D1',
                      backgroundColor: '#45B7D1',
                      tension: 0.1
                    }
                  ]
                }}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: { 
                      display: true, 
                      position: 'top',
                      labels: {
                        color: '#FFFFFF',
                        usePointStyle: true
                      }
                    },
                    tooltip: {
                      callbacks: {
                        label: function(context) {
                          return `${context.dataset.label}: ${context.parsed.y} elementos`;
                        }
                      }
                    }
                  },
                  scales: {
                    x: {
                      ticks: { color: '#FFFFFF' },
                      grid: { color: '#5B696F' }
                    },
                    y: {
                      beginAtZero: true,
                      ticks: { color: '#FFFFFF' },
                      grid: { color: '#5B696F' }
                    }
                  }
                }}
              />
            </div>
          </div>

          {/* Resumen de Actividad */}
          <div style={{ 
            backgroundColor: '#1E2B38', 
            padding: '20px', 
            borderRadius: '8px', 
            border: '1px solid #ADC7EA'
          }}>
            <h5 style={{ margin: '0 0 15px 0', color: '#ADC7EA' }}>
              Resumen de Actividad por Tipo
            </h5>
            <div className="overview-cards">
              {['documentos', 'predicciones', 'registros_medicos'].map(tipo => {
                const totalTipo = frecuenciaDiariaData
                  .filter(item => item.tipo_contenido === tipo)
                  .reduce((sum, item) => sum + item.cantidad, 0);
                const diasConActividad = frecuenciaDiariaData
                  .filter(item => item.tipo_contenido === tipo && item.cantidad > 0).length;
                
                return (
                  <div key={tipo} className="kpi-card">
                    <h4 style={{ textTransform: 'capitalize' }}>
                      {tipo.replace('_', ' ')}
                    </h4>
                    <p style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#FFFFFF' }}>
                      {totalTipo}
                    </p>
                    <p style={{ fontSize: '0.9rem', color: '#ADC7EA', margin: '5px 0 0 0' }}>
                      con actividad <ActividadBadge dias={diasConActividad} />
                    </p>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {activeSection === 'crecimiento-semanal' && crecimientoSemanalData && (
        <div className="table-card">
          <h4>Crecimiento Semanal de Contenido</h4>
          
          <div style={{ marginBottom: '20px', padding: '15px', backgroundColor: '#1E2B38', borderRadius: '8px', border: '1px solid #ADC7EA' }}>
            <h5 style={{ margin: '0 0 10px 0', color: '#ADC7EA' }}>Tendencias de Crecimiento</h5>
            <p style={{ margin: '0', fontSize: '14px', color: '#FFFFFF' }}>
              Análisis del crecimiento semanal de contenido en las últimas 12 semanas. Incluye documentos y predicciones.
            </p>
          </div>

          {/* Gráfico de Barras */}
          <div style={{ 
            backgroundColor: '#1E2B38', 
            padding: '20px', 
            borderRadius: '8px', 
            border: '1px solid #ADC7EA',
            marginBottom: '20px'
          }}>
            <h5 style={{ margin: '0 0 15px 0', color: '#ADC7EA', textAlign: 'center' }}>
              Crecimiento Semanal por Tipo de Contenido
            </h5>
            <div style={{ height: '400px' }}>
              <Bar 
                data={{
                  labels: [...new Set(crecimientoSemanalData.map(item => 
                    new Date(item.semana).toLocaleDateString('es-ES', { 
                      month: 'short', 
                      day: 'numeric' 
                    })
                  ))].sort((a, b) => new Date(a) - new Date(b)),
                  datasets: [
                    {
                      label: 'Documentos',
                      data: crecimientoSemanalData
                        .filter(item => item.tipo_contenido === 'documentos')
                        .map(item => item.cantidad),
                      backgroundColor: '#4ECDC4',
                      borderColor: '#4ECDC4',
                      borderWidth: 1
                    },
                    {
                      label: 'Predicciones',
                      data: crecimientoSemanalData
                        .filter(item => item.tipo_contenido === 'predicciones')
                        .map(item => item.cantidad),
                      backgroundColor: '#96CEB4',
                      borderColor: '#96CEB4',
                      borderWidth: 1
                    }
                  ]
                }}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: { 
                      display: true, 
                      position: 'top',
                      labels: {
                        color: '#FFFFFF',
                        usePointStyle: true
                      }
                    },
                    tooltip: {
                      callbacks: {
                        label: function(context) {
                          return `${context.dataset.label}: ${context.parsed.y} elementos`;
                        }
                      }
                    }
                  },
                  scales: {
                    x: {
                      ticks: { color: '#FFFFFF' },
                      grid: { color: '#5B696F' }
                    },
                    y: {
                      beginAtZero: true,
                      ticks: { color: '#FFFFFF' },
                      grid: { color: '#5B696F' }
                    }
                  }
                }}
              />
            </div>
          </div>

          {/* Resumen de Crecimiento */}
          <div style={{ 
            backgroundColor: '#1E2B38', 
            padding: '20px', 
            borderRadius: '8px', 
            border: '1px solid #ADC7EA'
          }}>
            <h5 style={{ margin: '0 0 15px 0', color: '#ADC7EA' }}>
              Resumen de Crecimiento por Tipo
            </h5>
            <div className="overview-cards">
              {['documentos', 'predicciones'].map(tipo => {
                const totalTipo = crecimientoSemanalData
                  .filter(item => item.tipo_contenido === tipo)
                  .reduce((sum, item) => sum + item.cantidad, 0);
                const semanasConActividad = crecimientoSemanalData
                  .filter(item => item.tipo_contenido === tipo && item.cantidad > 0).length;
                const promedioSemanal = semanasConActividad > 0 ? Math.round(totalTipo / semanasConActividad) : 0;
                
                return (
                  <div key={tipo} className="kpi-card">
                    <h4 style={{ textTransform: 'capitalize' }}>
                      {tipo}
                    </h4>
                    <p style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#FFFFFF' }}>
                      {totalTipo}
                    </p>
                    <p style={{ fontSize: '0.9rem', color: '#ADC7EA', margin: '5px 0 0 0' }}>
                      {semanasConActividad} semanas <ActividadBadge dias={semanasConActividad} />
                    </p>
                    <p style={{ fontSize: '0.8rem', color: '#9DB3C1', margin: '3px 0 0 0' }}>
                      Promedio: {promedioSemanal}/semana
                    </p>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {activeSection === 'actividad-usuarios' && actividadUsuariosData && (
        <div className="table-card">
          <h4>Actividad Diaria de Usuarios</h4>
          
          <div style={{ marginBottom: '20px', padding: '15px', backgroundColor: '#1E2B38', borderRadius: '8px', border: '1px solid #ADC7EA' }}>
            <h5 style={{ margin: '0 0 10px 0', color: '#ADC7EA' }}>Engagement de Usuarios</h5>
            <p style={{ margin: '0', fontSize: '14px', color: '#FFFFFF' }}>
              Análisis de la actividad diaria de usuarios en los últimos 30 días. Incluye usuarios activos y nuevos registros.
            </p>
          </div>

          {/* Gráfico de Líneas */}
          <div style={{ 
            backgroundColor: '#1E2B38', 
            padding: '20px', 
            borderRadius: '8px', 
            border: '1px solid #ADC7EA',
            marginBottom: '20px'
          }}>
            <h5 style={{ margin: '0 0 15px 0', color: '#ADC7EA', textAlign: 'center' }}>
              Tendencia de Actividad de Usuarios
            </h5>
            <div style={{ height: '400px' }}>
              <Line 
                data={{
                  labels: actividadUsuariosData.map(item => 
                    new Date(item.fecha).toLocaleDateString('es-ES', { 
                      month: 'short', 
                      day: 'numeric' 
                    })
                  ).sort((a, b) => new Date(a) - new Date(b)),
                  datasets: [
                    {
                      label: 'Usuarios Activos',
                      data: actividadUsuariosData.map(item => item.usuarios_activos),
                      borderColor: '#4ECDC4',
                      backgroundColor: '#4ECDC4',
                      tension: 0.1,
                      fill: false
                    },
                    {
                      label: 'Usuarios Nuevos',
                      data: actividadUsuariosData.map(item => item.usuarios_nuevos),
                      borderColor: '#96CEB4',
                      backgroundColor: '#96CEB4',
                      tension: 0.1,
                      fill: false
                    }
                  ]
                }}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: { 
                      display: true, 
                      position: 'top',
                      labels: {
                        color: '#FFFFFF',
                        usePointStyle: true
                      }
                    },
                    tooltip: {
                      callbacks: {
                        label: function(context) {
                          return `${context.dataset.label}: ${context.parsed.y} usuarios`;
                        }
                      }
                    }
                  },
                  scales: {
                    x: {
                      ticks: { color: '#FFFFFF' },
                      grid: { color: '#5B696F' }
                    },
                    y: {
                      beginAtZero: true,
                      ticks: { color: '#FFFFFF' },
                      grid: { color: '#5B696F' }
                    }
                  }
                }}
              />
            </div>
          </div>

          {/* Resumen de Actividad */}
          <div style={{ 
            backgroundColor: '#1E2B38', 
            padding: '20px', 
            borderRadius: '8px', 
            border: '1px solid #ADC7EA'
          }}>
            <h5 style={{ margin: '0 0 15px 0', color: '#ADC7EA' }}>
              Resumen de Actividad de Usuarios
            </h5>
            <div className="overview-cards">
              <div className="kpi-card">
                <h4>Usuarios Activos</h4>
                <p style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#FFFFFF' }}>
                  {actividadUsuariosData.reduce((sum, item) => sum + item.usuarios_activos, 0)}
                </p>
                <p style={{ fontSize: '0.9rem', color: '#ADC7EA', margin: '5px 0 0 0' }}>
                  Total de actividad en {actividadUsuariosData.length} días
                </p>
              </div>

              <div className="kpi-card">
                <h4>Usuarios Nuevos</h4>
                <p style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#FFFFFF' }}>
                  {actividadUsuariosData.reduce((sum, item) => sum + item.usuarios_nuevos, 0)}
                </p>
                <p style={{ fontSize: '0.9rem', color: '#ADC7EA', margin: '5px 0 0 0' }}>
                  Nuevos registros en {actividadUsuariosData.length} días
                </p>
              </div>

              <div className="kpi-card">
                <h4>Promedio Diario</h4>
                <p style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#FFFFFF' }}>
                  {Math.round(actividadUsuariosData.reduce((sum, item) => sum + item.usuarios_activos, 0) / actividadUsuariosData.length)}
                </p>
                <p style={{ fontSize: '0.9rem', color: '#ADC7EA', margin: '5px 0 0 0' }}>
                  Usuarios activos por día
                </p>
              </div>

              <div className="kpi-card">
                <h4>Pico de Actividad</h4>
                <p style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#FFFFFF' }}>
                  {Math.max(...actividadUsuariosData.map(item => item.usuarios_activos))}
                </p>
                <p style={{ fontSize: '0.9rem', color: '#ADC7EA', margin: '5px 0 0 0' }}>
                  Máximo en un día
                </p>
              </div>
            </div>
          </div>
        </div>
      )}

      {activeSection === 'resumen-ejecutivo' && resumenEjecutivoData && (
        <>
          <h4 style={{ margin: '0 0 15px 0', color: '#ADC7EA', fontSize: '1.2rem' }}>Resumen Ejecutivo del Sistema</h4>
          
          <div>
          
          {/* Contenedor 1: Métricas Principales */}
          <div className="table-card" style={{ marginBottom: '20px' }}>
            <div style={{ marginBottom: '20px', padding: '15px', backgroundColor: '#1E2B38', borderRadius: '8px', border: '1px solid #ADC7EA' }}>
              <h5 style={{ margin: '0 0 10px 0', color: '#ADC7EA' }}>Métricas Principales del Sistema</h5>
              <p style={{ margin: '0', fontSize: '14px', color: '#FFFFFF' }}>
                Total de usuarios, predicciones, registros médicos y documentos en el sistema.
              </p>
            </div>
            
            <div className="overview-cards">
              <div className="kpi-card">
                <h4>Total de Usuarios</h4>
                <p>{resumenEjecutivoData.total_usuarios}</p>
              </div>

              <div className="kpi-card">
                <h4>Predicciones Generadas</h4>
                <p>{resumenEjecutivoData.total_predicciones}</p>
              </div>

              <div className="kpi-card">
                <h4>Registros Médicos</h4>
                <p>{resumenEjecutivoData.total_registros_medicos}</p>
              </div>

              <div className="kpi-card">
                <h4>Documentos Subidos</h4>
                <p>{resumenEjecutivoData.total_documentos}</p>
              </div>
            </div>
          </div>

          {/* Contenedor 2: Actividad Reciente */}
          <div className="table-card" style={{ marginBottom: '20px' }}>
            <div style={{ marginBottom: '20px', padding: '15px', backgroundColor: '#1E2B38', borderRadius: '8px', border: '1px solid #ADC7EA' }}>
              <h5 style={{ margin: '0 0 10px 0', color: '#ADC7EA' }}>Actividad de la Última Semana</h5>
              <p style={{ margin: '0', fontSize: '14px', color: '#FFFFFF' }}>
                Usuarios activos y contenido generado en los últimos 7 días.
              </p>
            </div>

            <div className="overview-cards">
              <div className="kpi-card">
                <h4>Usuarios Activos</h4>
                <p>{resumenEjecutivoData.usuarios_activos_semana}</p>
              </div>

              <div className="kpi-card">
                <h4>Predicciones Esta Semana</h4>
                <p>{resumenEjecutivoData.predicciones_semana}</p>
              </div>

              <div className="kpi-card">
                <h4>Documentos Esta Semana</h4>
                <p>{resumenEjecutivoData.documentos_semana}</p>
              </div>
            </div>
          </div>

          {/* Contenedor 3: Tendencias de Crecimiento */}
          <div className="table-card">
            <div style={{ marginBottom: '20px', padding: '15px', backgroundColor: '#1E2B38', borderRadius: '8px', border: '1px solid #ADC7EA' }}>
              <h5 style={{ margin: '0 0 10px 0', color: '#ADC7EA' }}>Tendencias de Crecimiento</h5>
              <p style={{ margin: '0', fontSize: '14px', color: '#FFFFFF' }}>
                Porcentajes de crecimiento y última actualización de datos.
              </p>
            </div>

            <div className="overview-cards">
              <div className="kpi-card">
                <h4>Crecimiento de Usuarios</h4>
                <p>{resumenEjecutivoData.crecimiento_usuarios_porcentaje}%</p>
              </div>

              <div className="kpi-card">
                <h4>Crecimiento de Documentos</h4>
                <p>{resumenEjecutivoData.crecimiento_documentos_porcentaje}%</p>
              </div>

              <div className="kpi-card">
                <h4>Última Actualización</h4>
                <p>{new Date(resumenEjecutivoData.fecha_actualizacion).toLocaleDateString('es-ES', {
                  year: 'numeric',
                  month: 'short',
                  day: 'numeric',
                  hour: '2-digit',
                  minute: '2-digit'
                })}</p>
              </div>
            </div>
          </div>
          
          </div>
        </>
      )}
    </div>
  );
}