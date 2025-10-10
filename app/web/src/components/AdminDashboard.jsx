import React, { useState, useEffect } from 'react';
import { Line, Pie, Bar } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler
} from 'chart.js';
import RetryButton from './RetryButton';
import LoadingSpinner from './LoadingSpinner';
import ErrorDisplay from './ErrorDisplay';
import useRetry from '../hooks/useRetry';
import retryService from '../services/retryService';
import '../styles.css';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

const API_BASE_URL = 'http://localhost:5001/api';

export default function AdminDashboard({ patients }) {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [prediccionesPorMes, setPrediccionesPorMes] = useState(null);
  const [distribucionEnfermedades, setDistribucionEnfermedades] = useState(null);
  const [estadoDocumentos, setEstadoDocumentos] = useState(null);
  const [distribucionDemografica, setDistribucionDemografica] = useState(null);
  const [crecimientoUsuarios, setCrecimientoUsuarios] = useState(null);
  const [topUsuariosActivos, setTopUsuariosActivos] = useState(null);

  // Función para obtener datos de predicciones por mes
  const fetchPrediccionesPorMes = async () => {
    const token = localStorage.getItem('token');
    if (!token) {
      throw new Error('No hay token de autenticación');
    }

      const response = await fetch(`${API_BASE_URL}/dashboard/graficos/predicciones-por-mes`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error(`Error ${response.status}: ${response.statusText}`);
    }

    const data = await response.json();
    if (data.success) {
      setPrediccionesPorMes(data.data);
    } else {
      throw new Error(data.error || 'Error al obtener datos');
    }
  };

  // Función para obtener datos de distribución de enfermedades
  const fetchDistribucionEnfermedades = async () => {
    const token = localStorage.getItem('token');
    if (!token) {
      throw new Error('No hay token de autenticación');
    }

      const response = await fetch(`${API_BASE_URL}/dashboard/graficos/distribucion-enfermedades`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error(`Error ${response.status}: ${response.statusText}`);
    }

    const data = await response.json();
    if (data.success) {
      setDistribucionEnfermedades(data.data);
    } else {
      throw new Error(data.error || 'Error al obtener datos');
    }
  };

  // Función para obtener datos de estado de documentos
  const fetchEstadoDocumentos = async () => {
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        throw new Error('No hay token de autenticación');
      }

      const response = await fetch(`${API_BASE_URL}/dashboard/graficos/estado-documentos`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`Error ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      if (data.success) {
        setEstadoDocumentos(data.data);
      } else {
        throw new Error(data.error || 'Error al obtener datos');
      }
    } catch (err) {
      console.error('Error fetching estado documentos:', err);
      setEstadoDocumentos([]);
    }
  };

  // Función para obtener datos de distribución demográfica
  const fetchDistribucionDemografica = async () => {
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        throw new Error('No hay token de autenticación');
      }

      const response = await fetch(`${API_BASE_URL}/dashboard/graficos/distribucion-demografica`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`Error ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      if (data.success) {
        setDistribucionDemografica(data.data);
      } else {
        throw new Error(data.error || 'Error al obtener datos');
      }
    } catch (err) {
      console.error('Error fetching distribución demográfica:', err);
      setDistribucionDemografica([]);
    }
  };

  // Función para obtener datos de crecimiento acumulado de usuarios
  const fetchCrecimientoUsuarios = async () => {
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        throw new Error('No hay token de autenticación');
      }

      const response = await fetch(`${API_BASE_URL}/dashboard/graficos/crecimiento-acumulado-usuarios`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`Error ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      if (data.success) {
        setCrecimientoUsuarios(data.data);
      } else {
        throw new Error(data.error || 'Error al obtener datos');
      }
    } catch (err) {
      console.error('Error fetching crecimiento usuarios:', err);
      setCrecimientoUsuarios([]);
    }
  };

  // Función para obtener datos de top usuarios activos
  const fetchTopUsuariosActivos = async () => {
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        throw new Error('No hay token de autenticación');
      }

      const response = await fetch(`${API_BASE_URL}/dashboard/graficos/top-usuarios-activos`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`Error ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      if (data.success) {
        setTopUsuariosActivos(data.data);
      } else {
        throw new Error(data.error || 'Error al obtener datos');
      }
    } catch (err) {
      console.error('Error fetching top usuarios activos:', err);
      setTopUsuariosActivos([]);
    }
  };

  // Función para recargar datos con retry automático
  const reloadData = async () => {
    setLoading(true);
    setError(null);
    
    // Resetear todos los estados
    setPrediccionesPorMes(null);
    setDistribucionEnfermedades(null);
    setEstadoDocumentos(null);
    setDistribucionDemografica(null);
    setCrecimientoUsuarios(null);
    setTopUsuariosActivos(null);
    
    // Intentar cargar cada endpoint individualmente con retry
    const endpoints = [
      { name: 'graficos/predicciones-por-mes', setter: setPrediccionesPorMes },
      { name: 'graficos/distribucion-enfermedades', setter: setDistribucionEnfermedades },
      { name: 'graficos/estado-documentos', setter: setEstadoDocumentos },
      { name: 'graficos/distribucion-demografica', setter: setDistribucionDemografica },
      { name: 'graficos/crecimiento-acumulado-usuarios', setter: setCrecimientoUsuarios },
      { name: 'graficos/top-usuarios-activos', setter: setTopUsuariosActivos }
    ];
    
    let hasError = false;
    let errorMessage = '';
    
    let loadedCount = 0;
    const totalEndpoints = endpoints.length;
    
    for (const endpoint of endpoints) {
      try {
        const token = localStorage.getItem('token');
        if (!token) {
          throw new Error('No hay token de autenticación');
        }

        console.log(`Intentando conectar a: ${API_BASE_URL}/dashboard/${endpoint.name}`);
        
        // Usar retryService para hacer fetch con retry automático
        const result = await retryService.fetchJsonWithRetrySilent(
          `${API_BASE_URL}/dashboard/${endpoint.name}`,
          {
            method: 'GET',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json'
            }
          },
          {
            maxRetries: 3,
            baseDelay: 1000,
            onRetry: (attempt, error) => {
              console.log(`Reintentando ${endpoint.name} (intento ${attempt + 1})...`);
            }
          }
        );
        
        console.log(`Resultado para ${endpoint.name}:`, result);
        
        if (result.success) {
          if (result.data.success) {
            endpoint.setter(result.data.data);
            loadedCount++;
            console.log(`✅ ${endpoint.name} cargado exitosamente (${loadedCount}/${totalEndpoints})`);
            
            // Si es el primer endpoint que se carga exitosamente, ocultar spinner
            if (loadedCount === 1) {
              setLoading(false);
            }
          } else {
            throw new Error(result.data.error || 'Error al obtener datos');
          }
        } else {
          throw new Error(result.error);
        }
      } catch (err) {
        console.error(`Error fetching ${endpoint.name}:`, err);
        endpoint.setter([]);
        hasError = true;
        errorMessage = err.message;
      }
    }
    
    if (hasError) {
      setError(errorMessage);
    }
    
    // Asegurar que el loading se oculte al final
    setLoading(false);
  };

  // Cargar datos al montar el componente
  useEffect(() => {
    reloadData();
  }, []);

  // Configuración de colores
  const COLORS = ['#4ECDC4', '#96CEB4', '#45B7D1', '#FF6B6B', '#FFD93D', '#9DB3C1'];

  // Datos para gráfico de Predicciones por Mes (Líneas)
  const prediccionesData = prediccionesPorMes && prediccionesPorMes.length > 0 ? {
    labels: prediccionesPorMes.map(item => new Date(item.mes).toLocaleDateString('es-ES', { month: 'short', year: 'numeric' })),
    datasets: [{
      label: 'Total Predicciones',
      data: prediccionesPorMes.map(item => item.total_predicciones),
      borderColor: '#4ECDC4',
      backgroundColor: 'rgba(78, 205, 196, 0.1)',
      fill: true,
      tension: 0.4,
      pointBackgroundColor: '#4ECDC4',
      pointBorderColor: '#4ECDC4',
      pointRadius: 4
    }, {
      label: 'Predicciones Positivas',
      data: prediccionesPorMes.map(item => item.predicciones_positivas),
      borderColor: '#FF6B6B',
      backgroundColor: 'rgba(255, 107, 107, 0.1)',
      fill: false,
      tension: 0.4,
      pointBackgroundColor: '#FF6B6B',
      pointBorderColor: '#FF6B6B',
      pointRadius: 4
    }, {
      label: 'Predicciones Negativas',
      data: prediccionesPorMes.map(item => item.predicciones_negativas),
      borderColor: '#FFD93D',
      backgroundColor: 'rgba(255, 217, 61, 0.1)',
      fill: false,
      tension: 0.4,
      pointBackgroundColor: '#FFD93D',
      pointBorderColor: '#FFD93D',
      pointRadius: 4
    }]
  } : null;

  // Datos para gráfico de Distribución de Enfermedades (Pastel)
  const enfermedadesData = distribucionEnfermedades && distribucionEnfermedades.length > 0 ? {
    labels: distribucionEnfermedades.map(item => item.enfermedad),
    datasets: [{
      data: distribucionEnfermedades.map(item => item.casos),
      backgroundColor: COLORS.slice(0, distribucionEnfermedades.length),
      borderWidth: 2,
      borderColor: '#1E2B38'
    }]
  } : null;

  // Datos para gráfico de Estado de Documentos (Barras)
  const documentosData = estadoDocumentos && estadoDocumentos.length > 0 ? {
    labels: ['Estados'],
    datasets: estadoDocumentos.map((item, index) => ({
      label: item.estado,
      data: [item.cantidad],
      backgroundColor: COLORS[index % COLORS.length],
      borderColor: '#1E2B38',
      borderWidth: 1
    }))
  } : null;

  // Datos para gráfico de Distribución Demográfica (Barras Agrupadas)
  const demograficaData = distribucionDemografica && distribucionDemografica.length > 0 ? {
    labels: [...new Set(distribucionDemografica.map(item => item.grupo_edad))],
    datasets: [
      {
        label: 'Masculino',
        data: [...new Set(distribucionDemografica.map(item => item.grupo_edad))].map(edad => {
          const item = distribucionDemografica.find(d => d.grupo_edad === edad && d.sexo === 'M');
          return item ? item.cantidad : 0;
        }),
        backgroundColor: '#4ECDC4',
        borderColor: '#1E2B38',
        borderWidth: 1
      },
      {
        label: 'Femenino',
        data: [...new Set(distribucionDemografica.map(item => item.grupo_edad))].map(edad => {
          const item = distribucionDemografica.find(d => d.grupo_edad === edad && d.sexo === 'F');
          return item ? item.cantidad : 0;
        }),
        backgroundColor: '#FF6B6B',
        borderColor: '#1E2B38',
        borderWidth: 1
      },
      {
        label: 'No especificado',
        data: [...new Set(distribucionDemografica.map(item => item.grupo_edad))].map(edad => {
          const item = distribucionDemografica.find(d => d.grupo_edad === edad && d.sexo !== 'M' && d.sexo !== 'F');
          return item ? item.cantidad : 0;
        }),
        backgroundColor: '#96CEB4',
        borderColor: '#1E2B38',
        borderWidth: 1
      }
    ]
  } : null;

  // Datos para gráfico de Crecimiento Acumulado de Usuarios (Área)
  const crecimientoData = crecimientoUsuarios && crecimientoUsuarios.length > 0 ? {
    labels: crecimientoUsuarios.map(item => new Date(item.mes).toLocaleDateString('es-ES', { month: 'short', year: 'numeric' })),
    datasets: [{
      label: 'Usuarios Acumulados',
      data: crecimientoUsuarios.map(item => parseInt(item.usuarios_acumulados)),
      borderColor: '#4ECDC4',
      backgroundColor: 'rgba(78, 205, 196, 0.2)',
      fill: true,
      tension: 0.4,
      pointBackgroundColor: '#4ECDC4',
      pointBorderColor: '#4ECDC4',
      pointRadius: 4
    }, {
      label: 'Usuarios Nuevos',
      data: crecimientoUsuarios.map(item => parseInt(item.usuarios_nuevos)),
      borderColor: '#FF6B6B',
      backgroundColor: 'rgba(255, 107, 107, 0.2)',
      fill: false,
      tension: 0.4,
      pointBackgroundColor: '#FF6B6B',
      pointBorderColor: '#FF6B6B',
      pointRadius: 4
    }]
  } : null;

  // Datos para gráfico de Top 5 Usuarios Más Activos (Barras Verticales)
  const usuariosActivosData = topUsuariosActivos && topUsuariosActivos.length > 0 ? {
    labels: topUsuariosActivos.map(item => `ID: ${item.id_usuario}`),
    datasets: [
      {
        label: 'Actividad Total',
        data: topUsuariosActivos.map(item => parseInt(item.actividad_total)),
        backgroundColor: '#4ECDC4',
        borderColor: '#1E2B38',
        borderWidth: 1
      },
      {
        label: 'Documentos Subidos',
        data: topUsuariosActivos.map(item => parseInt(item.documentos_subidos)),
        backgroundColor: '#96CEB4',
        borderColor: '#1E2B38',
        borderWidth: 1
      },
      {
        label: 'Predicciones Realizadas',
        data: topUsuariosActivos.map(item => parseInt(item.predicciones_realizadas)),
        backgroundColor: '#45B7D1',
        borderColor: '#1E2B38',
        borderWidth: 1
      },
      {
        label: 'Signos Vitales Registrados',
        data: topUsuariosActivos.map(item => parseInt(item.signos_vitales_registrados)),
        backgroundColor: '#FF6B6B',
        borderColor: '#1E2B38',
        borderWidth: 1
      }
    ]
  } : null;

  if (loading) {
    return (
      <div className="admin-dashboard">
        <div className="dashboard-header">
          <h1>Dashboard</h1>
        </div>
        <LoadingSpinner 
          message="Cargando datos del dashboard..."
          variant="dots"
          size="large"
        />
      </div>
    );
  }

  if (error) {
    return (
      <div className="admin-dashboard">
        <div className="dashboard-header">
          <h1>Dashboard</h1>
        </div>
        <ErrorDisplay
          title="Error al cargar los datos"
          message={error}
          type="network"
          onRetry={reloadData}
          showRetry={true}
        />
      </div>
    );
  }

  return (
    <div className="admin-dashboard">
      <div className="dashboard-header">
        <h1>Dashboard</h1>
      </div>

      <div className="dashboard-grid">
        {/* Sección 1: Predicciones por Mes */}
        <div className="dashboard-section">
          <h4>Predicciones por Mes</h4>
          {prediccionesData ? (
            <div style={{ height: '300px', width: '100%' }}>
              <Line 
                data={prediccionesData} 
                options={{ 
                  responsive: true, 
                  maintainAspectRatio: false,
                  plugins: { 
                    legend: { 
                      display: true, 
                      position: 'top',
                      labels: {
                        color: '#ADC7EA',
                        font: {
                          size: 12
                        }
                      }
                    },
                    title: { display: false }
                  },
                  scales: {
                    y: { 
                      beginAtZero: true,
                      grid: {
                        color: 'rgba(157, 179, 193, 0.2)'
                      },
                      ticks: {
                        color: '#9DB3C1'
                      }
                    },
                    x: {
                      grid: {
                        color: 'rgba(157, 179, 193, 0.2)'
                      },
                      ticks: {
                        color: '#9DB3C1'
                      }
                    }
                  }
                }} 
              />
            </div>
          ) : (
            <p style={{ fontStyle: 'italic', color: '#9DB3C1' }}>No hay datos disponibles</p>
          )}
        </div>

        {/* Sección 2: Distribución de Enfermedades */}
        <div className="dashboard-section">
          <h4>Distribución de Enfermedades</h4>
          {enfermedadesData ? (
            <div style={{ height: '300px', width: '100%' }}>
              <Pie 
                data={enfermedadesData} 
                options={{ 
                  responsive: true, 
                  maintainAspectRatio: false,
                  plugins: { 
                    legend: { 
                      display: true, 
                      position: 'bottom',
                      labels: {
                        color: '#ADC7EA',
                        font: {
                          size: 12
                        }
                      }
                    },
                    title: { display: false }
                  }
                }} 
              />
            </div>
          ) : (
            <p style={{ fontStyle: 'italic', color: '#9DB3C1' }}>No hay datos disponibles</p>
          )}
        </div>

        {/* Sección 3: Estado de Documentos */}
        <div className="dashboard-section">
          <h4>Estado de Documentos</h4>
          {documentosData ? (
            <div style={{ height: '300px', width: '100%' }}>
              <Bar 
                data={documentosData} 
                options={{ 
                  responsive: true, 
                  maintainAspectRatio: false,
                  plugins: { 
                    legend: { 
                      display: true,
                      position: 'top',
                      labels: {
                        color: '#ADC7EA',
                        font: {
                          size: 12
                        }
                      }
                    },
                    title: { display: false }
                  },
                  scales: {
                    y: { 
                      beginAtZero: true,
                      grid: {
                        color: 'rgba(157, 179, 193, 0.2)'
                      },
                      ticks: {
                        color: '#9DB3C1'
                      }
                    },
                    x: {
                      grid: {
                        color: 'rgba(157, 179, 193, 0.2)'
                      },
                      ticks: {
                        color: '#9DB3C1'
                      }
                    }
                  }
                }} 
              />
      </div>
          ) : (
            <p style={{ fontStyle: 'italic', color: '#9DB3C1' }}>No hay datos disponibles</p>
          )}
        </div>

        {/* Sección 4: Distribución Demográfica */}
        <div className="dashboard-section">
          <h4>Distribución Demográfica</h4>
          {demograficaData ? (
            <div style={{ height: '300px', width: '100%' }}>
              <Bar 
                data={demograficaData} 
                options={{ 
                  responsive: true, 
                  maintainAspectRatio: false,
                  indexAxis: 'y',
                  plugins: { 
                    legend: { 
                      display: true,
                      position: 'top',
                      labels: {
                        color: '#ADC7EA',
                        font: {
                          size: 12
                        }
                      }
                    },
                    title: { display: false }
                  },
                  scales: {
                    x: { 
                      beginAtZero: true,
                      title: {
                        display: true,
                        text: 'Cantidad de Usuarios',
                        color: '#ADC7EA',
                        font: {
                          size: 12,
                          weight: 'bold'
                        }
                      },
                      grid: {
                        color: 'rgba(157, 179, 193, 0.2)'
                      },
                      ticks: {
                        color: '#9DB3C1'
                      }
                    },
                    y: {
                      title: {
                        display: true,
                        text: 'Grupos de Edad',
                        color: '#ADC7EA',
                        font: {
                          size: 12,
                          weight: 'bold'
                        }
                      },
                      grid: {
                        color: 'rgba(157, 179, 193, 0.2)'
                      },
                      ticks: {
                        color: '#9DB3C1'
                      }
                    }
                  }
                }} 
              />
            </div>
          ) : (
            <p style={{ fontStyle: 'italic', color: '#9DB3C1' }}>No hay datos disponibles</p>
          )}
        </div>

        {/* Sección 5: Crecimiento Acumulado de Usuarios */}
        <div className="dashboard-section">
          <h4>Crecimiento Acumulado de Usuarios</h4>
          {crecimientoData ? (
            <div style={{ height: '300px', width: '100%' }}>
              <Line 
                data={crecimientoData} 
                options={{ 
                  responsive: true, 
                  maintainAspectRatio: false,
                  plugins: { 
                    legend: { 
                      display: true, 
                      position: 'top',
                      labels: {
                        color: '#ADC7EA',
                        font: {
                          size: 12
                        }
                      }
                    },
                    title: { display: false }
                  },
                  scales: {
                    y: { 
                      beginAtZero: true,
                      title: {
                        display: true,
                        text: 'Cantidad de Usuarios',
                        color: '#ADC7EA',
                        font: {
                          size: 12,
                          weight: 'bold'
                        }
                      },
                      grid: {
                        color: 'rgba(157, 179, 193, 0.2)'
                      },
                      ticks: {
                        color: '#9DB3C1'
                      }
                    },
                    x: {
                      title: {
                        display: true,
                        text: 'Meses',
                        color: '#ADC7EA',
                        font: {
                          size: 12,
                          weight: 'bold'
                        }
                      },
                      grid: {
                        color: 'rgba(157, 179, 193, 0.2)'
                      },
                      ticks: {
                        color: '#9DB3C1'
                      }
                    }
                  }
                }} 
              />
            </div>
          ) : (
            <p style={{ fontStyle: 'italic', color: '#9DB3C1' }}>No hay datos disponibles</p>
          )}
        </div>

        {/* Sección 6: Top 5 Usuarios Más Activos */}
        <div className="dashboard-section">
          <h4>Top 5 Usuarios Más Activos</h4>
          {usuariosActivosData ? (
            <div style={{ height: '300px', width: '100%' }}>
              <Bar 
                data={usuariosActivosData} 
                options={{ 
                  responsive: true, 
                  maintainAspectRatio: false,
                  plugins: { 
                    legend: { 
                      display: true,
                      position: 'top',
                      labels: {
                        color: '#ADC7EA',
                        font: {
                          size: 12
                        }
                      }
                    },
                    title: { display: false }
                  },
                  scales: {
                    y: { 
                      beginAtZero: true,
                      title: {
                        display: true,
                        text: 'Puntos de Actividad',
                        color: '#ADC7EA',
                        font: {
                          size: 12,
                          weight: 'bold'
                        }
                      },
                      grid: {
                        color: 'rgba(157, 179, 193, 0.2)'
                      },
                      ticks: {
                        color: '#9DB3C1'
                      }
                    },
                    x: {
                      title: {
                        display: true,
                        text: 'Usuario',
                        color: '#ADC7EA',
                        font: {
                          size: 12,
                          weight: 'bold'
                        }
                      },
                      grid: {
                        color: 'rgba(157, 179, 193, 0.2)'
                      },
                      ticks: {
                        color: '#9DB3C1'
                      }
                    }
                  }
                }} 
              />
            </div>
          ) : (
            <p style={{ fontStyle: 'italic', color: '#9DB3C1' }}>No hay datos disponibles</p>
          )}
        </div>
      </div>
    </div>
  );
}
