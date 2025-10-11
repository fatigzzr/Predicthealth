import { useState, useEffect } from "react";
import { Line, Bar, Pie } from "react-chartjs-2";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  LineElement,
  PointElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
} from "chart.js";
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';
import Papa from 'papaparse';
import RetryButton from './RetryButton';
import LoadingSpinner from './LoadingSpinner';
import ErrorDisplay from './ErrorDisplay';
import retryService from '../services/retryService';
import '../styles.css';

ChartJS.register(CategoryScale, LinearScale, BarElement, LineElement, PointElement, Title, Tooltip, Legend, ArcElement);

// Funciones de exportación
const exportToPDF = async (sectionName, elementId) => {
  try {
    const element = document.getElementById(elementId);
    if (!element) {
      alert('No se encontró el elemento para exportar');
      return;
    }

    const canvas = await html2canvas(element, {
      scale: 2,
      useCORS: true,
      allowTaint: true
    });

    const imgData = canvas.toDataURL('image/png');
    const pdf = new jsPDF('p', 'mm', 'a4');
    const imgWidth = 210;
    const pageHeight = 295;
    const imgHeight = (canvas.height * imgWidth) / canvas.width;
    let heightLeft = imgHeight;

    let position = 0;

    pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
    heightLeft -= pageHeight;

    while (heightLeft >= 0) {
      position = heightLeft - imgHeight;
      pdf.addPage();
      pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
      heightLeft -= pageHeight;
    }

    pdf.save(`reporte-${sectionName}-${new Date().toISOString().split('T')[0]}.pdf`);
  } catch (error) {
    console.error('Error al exportar PDF:', error);
    alert('Error al generar el PDF');
  }
};

const exportToCSV = (data, sectionName) => {
  try {
    if (!data || data.length === 0) {
      alert('No hay datos para exportar');
      return;
    }

    let processedData = data;

    // Si los datos son arrays de arrays (como signos vitales), convertirlos a objetos
    if (Array.isArray(data) && data.length > 0 && Array.isArray(data[0])) {
      if (sectionName === 'signos-vitales') {
        processedData = data.map(item => ({
          'ID Usuario': item[0],
          'Fecha': item[1],
          'ID Postura': item[2],
          'Frecuencia Cardíaca Promedio': item[3] || 0,
          'Saturación Oxígeno Promedio': item[4] || 0,
          'Mediciones HR/Día': item[5] || 0,
          'Mediciones SpO2/Día': item[6] || 0
        }));
      } else if (sectionName === 'monitoreo-pa') {
        processedData = data.map(item => ({
          'ID Usuario': item[0],
          'Fecha': item[1],
          'PA Sistólica': item[2],
          'PA Diastólica': item[3],
          'Postura': item[4]
        }));
      } else if (sectionName === 'laboratorio') {
        processedData = data.map(item => ({
          'ID Usuario': item[0],
          'Fecha': item[1],
          'Analito': item[2],
          'Valor': item[3],
          'Unidad': item[4]
        }));
      } else if (sectionName === 'estilo-vida') {
        processedData = data.map(item => ({
          'ID Usuario': item[0],
          'ID Pregunta': item[1],
          'Pregunta': item[2],
          'Unidad': item[3],
          'Total Respuestas': item[4] || 0,
          'Primera Respuesta': item[5] ? new Date(item[5]).toLocaleDateString() : 'N/A',
          'Última Respuesta': item[6] ? new Date(item[6]).toLocaleDateString() : 'N/A',
          'Respuestas Sí': item[7] || 0,
          'Respuestas No': item[8] || 0,
          'Promedio Numérico': item[9] ? parseFloat(item[9]).toFixed(2) : 'N/A',
          'Valor Mínimo': item[10] ? parseFloat(item[10]).toFixed(2) : 'N/A',
          'Valor Máximo': item[11] ? parseFloat(item[11]).toFixed(2) : 'N/A',
          'Valores Únicos': item[12] || 'N/A',
          'Porcentaje Sí': item[13] ? parseFloat(item[13]).toFixed(2) + '%' : 'N/A'
        }));
      }
    }

    // Configurar opciones para Papa.unparse
    const csvOptions = {
      header: true,
      delimiter: ',',
      newline: '\n',
      quotes: true,
      quoteChar: '"',
      escapeChar: '"'
    };

    const csv = Papa.unparse(processedData, csvOptions);
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', `reporte-${sectionName}-${new Date().toISOString().split('T')[0]}.csv`);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  } catch (error) {
    console.error('Error al exportar CSV:', error);
    alert('Error al generar el CSV');
  }
};

// Componente de botones de exportación
function ExportButtons({ sectionName, sectionId, data }) {
  return (
    <div style={{ display: 'flex', gap: '10px' }}>
      <button 
        onClick={() => exportToPDF(sectionName, sectionId)}
        style={{
          padding: '8px 16px',
          backgroundColor: '#ADC7EA',
          color: '#1F2A36',
          border: 'none',
          borderRadius: '4px',
          cursor: 'pointer',
          fontSize: '14px',
          transition: 'background-color 0.3s',
          fontWeight: '500'
        }}
        onMouseOver={(e) => e.target.style.backgroundColor = '#9DB3C1'}
        onMouseOut={(e) => e.target.style.backgroundColor = '#ADC7EA'}
      >
        Exportar PDF
      </button>
      <button 
        onClick={() => exportToCSV(data, sectionName)}
        style={{
          padding: '8px 16px',
          backgroundColor: '#ADC7EA',
          color: '#1F2A36',
          border: 'none',
          borderRadius: '4px',
          cursor: 'pointer',
          fontSize: '14px',
          transition: 'background-color 0.3s',
          fontWeight: '500'
        }}
        onMouseOver={(e) => e.target.style.backgroundColor = '#9DB3C1'}
        onMouseOut={(e) => e.target.style.backgroundColor = '#ADC7EA'}
      >
        Exportar CSV
      </button>
    </div>
  );
}

// Tabs Component
function Tabs({ children }) {
  const [activeTab, setActiveTab] = useState(0);
  return (
    <div className="tabs">
      <div className="tab-buttons">
        {children.map((tab, i) => (
          <button
            key={i}
            className={activeTab === i ? "active" : ""}
            onClick={() => setActiveTab(i)}
          >
            {tab.props.label}
          </button>
        ))}
      </div>
      <div className="tab-content">{children[activeTab]}</div>
    </div>
  );
}

// Collapsible Card
function CollapsibleCard({ title, children }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="collapsible-card">
      <div className="card-header" onClick={() => setOpen(!open)}>
        <p>{title}</p>
        <span>{open ? "▲" : "▼"}</span>
      </div>
      {open && <div className="card-body">{children}</div>}
    </div>
  );
}

// Risk Badge for Blood Pressure
function BloodPressureBadge({ systolic, diastolic }) {
  let text = "Normal";
  let color = "#5B696F";
  let textColor = "#FFFFFF";

  if (systolic >= 140 || diastolic >= 90) {
    text = "Alto riesgo";
    color = "#FF6B6B";
    textColor = "#FFFFFF";
  } else if (systolic >= 120 || diastolic >= 80) {
    text = "Moderado";
    color = "#FFD93D";
    textColor = "#000000";
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
      {text}
    </span>
  );
}

// BMI Badge Component
function BMIBadge({ bmi }) {
  if (!bmi) return null;
  
  let status = '';
  let color = '';
  
  if (bmi < 18.5) {
    status = 'Bajo peso';
    color = '#4ECDC4';
  } else if (bmi >= 18.5 && bmi < 25) {
    status = 'Normal';
    color = '#96CEB4';
  } else if (bmi >= 25 && bmi < 30) {
    status = 'Sobrepeso';
    color = '#FF6B6B';
  } else if (bmi >= 30 && bmi < 35) {
    status = 'Obesidad I';
    color = '#45B7D1';
  } else if (bmi >= 35 && bmi < 40) {
    status = 'Obesidad II';
    color = '#FF9800';
  } else {
    status = 'Obesidad III';
    color = '#F44336';
  }
  
  return (
    <span 
      style={{
        backgroundColor: color,
        color: 'white',
        padding: '2px 6px',
        borderRadius: '4px',
        fontSize: '0.8rem',
        display: 'inline-block'
      }}
    >
      {status}
    </span>
  );
}

// Vital Signs Status Badge
function VitalSignsBadge({ type, value }) {
  let text = "Normal";
  let color = "#4CAF50";
  let textColor = "#FFFFFF";

  if (type === 'frecuencia_cardiaca') {
    if (value < 60) {
      text = "Bradicardia";
      color = "#FF9800";
    } else if (value > 100) {
      text = "Taquicardia";
      color = "#F44336";
    }
  } else if (type === 'temperatura') {
    if (value < 36.1) {
      text = "Hipotermia";
      color = "#2196F3";
    } else if (value > 37.2) {
      text = "Fiebre";
      color = "#F44336";
    }
  } else if (type === 'saturacion_oxigeno') {
    if (value < 95) {
      text = "Hipoxemia";
      color = "#F44336";
    }
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
      {text}
    </span>
  );
}

// Participation Level Badge
function ParticipationBadge({ value }) {
  if (!value) return null;
  
  let text = "Baja";
  let color = "#F44336";
  
  if (value >= 8) {
    text = "Excelente";
    color = "#4CAF50";
  } else if (value >= 6) {
    text = "Buena";
    color = "#8BC34A";
  } else if (value >= 4) {
    text = "Moderada";
    color = "#FF9800";
  }
  
  return (
    <span style={{
      backgroundColor: color,
      color: 'white',
      padding: '2px 6px',
      borderRadius: '4px',
      fontSize: '10px',
      fontWeight: 'bold',
      marginLeft: '5px'
    }}>
      {text}
    </span>
  );
}

// Normal Ranges Reference Component
function NormalRangesReference() {
  return (
    <div className="normal-ranges-card" style={{
      backgroundColor: 'transparent',
      border: '1px solid #ADC7EA',
      borderRadius: '8px',
      padding: '15px',
      marginBottom: '20px'
    }}>
      <h4 style={{ margin: '0 0 10px 0', color: '#ADC7EA' }}>Rangos Normales de Signos Vitales</h4>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '10px' }}>
        <div>
          <strong>Frecuencia Cardíaca:</strong> 60-100 bpm
        </div>
        <div>
          <strong>Temperatura:</strong> 36.1-37.2°C
        </div>
        <div>
          <strong>Saturación Oxígeno:</strong> ≥95%
        </div>
        <div>
          <strong>Presión Arterial:</strong> &lt;120/80 mmHg
        </div>
      </div>
    </div>
  );
}

export default function ReportesAnalisis() {
  const [monitoreoData, setMonitoreoData] = useState([]);
  const [stats, setStats] = useState(null);
  const [signosVitalesData, setSignosVitalesData] = useState([]);
  const [signosVitalesStats, setSignosVitalesStats] = useState(null);
  const [labData, setLabData] = useState([]);
  const [labStats, setLabStats] = useState(null);
  const [labChartsData, setLabChartsData] = useState(null);
  const [estiloVidaData, setEstiloVidaData] = useState([]);
  const [estiloVidaStats, setEstiloVidaStats] = useState(null);
  const [estiloVidaChartsData, setEstiloVidaChartsData] = useState(null);
  const [filterAnalito, setFilterAnalito] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [dateRange, setDateRange] = useState('all');
  const [selectedUserId, setSelectedUserId] = useState('all');
  const [selectedQuestion, setSelectedQuestion] = useState('all');
  const [activeSection, setActiveSection] = useState('monitoreo-pa');

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const token = localStorage.getItem('token');
      if (!token) {
        throw new Error('No hay token de autenticación');
      }

      // Definir todos los endpoints a cargar
      const baseUrl = `${window.location.protocol}//${window.location.hostname}:5001/api`;
      const endpoints = [
        { url: `${baseUrl}/dashboard/monitoreo-pa`, setter: setMonitoreoData, dataKey: 'data' },
        { url: `${baseUrl}/dashboard/monitoreo-pa-stats`, setter: setStats, dataKey: 'stats' },
        { url: `${baseUrl}/dashboard/signos-vitales`, setter: setSignosVitalesData, dataKey: 'data' },
        { url: `${baseUrl}/dashboard/signos-vitales-stats`, setter: setSignosVitalesStats, dataKey: 'stats' },
        { url: `${baseUrl}/dashboard/lab`, setter: setLabData, dataKey: 'data' },
        { url: `${baseUrl}/dashboard/lab/stats`, setter: setLabStats, dataKey: 'stats' },
        { url: `${baseUrl}/dashboard/lab/charts`, setter: setLabChartsData, dataKey: 'processedData' },
        { url: `${baseUrl}/dashboard/estilo-vida`, setter: setEstiloVidaData, dataKey: 'data' },
        { url: `${baseUrl}/dashboard/estilo-vida-stats`, setter: setEstiloVidaStats, dataKey: 'stats' },
        { url: `${baseUrl}/dashboard/estilo-vida-charts`, setter: setEstiloVidaChartsData, dataKey: null }
      ];

      let hasError = false;
      let errorMessage = '';

      // Cargar cada endpoint con retry automático
      let loadedCount = 0;
      const totalEndpoints = endpoints.length;
      
      for (const endpoint of endpoints) {
        try {
          console.log(`Cargando: ${endpoint.url}`);
          
          const result = await retryService.fetchJsonWithRetrySilent(
            endpoint.url,
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
                console.log(`Reintentando ${endpoint.url} (intento ${attempt + 1})...`);
              }
            }
          );

          if (result.success) {
            if (result.data.success) {
              const data = endpoint.dataKey ? result.data[endpoint.dataKey] : result.data;
              endpoint.setter(data || []);
              loadedCount++;
              console.log(`✅ Cargado exitosamente: ${endpoint.url} (${loadedCount}/${totalEndpoints})`);
              
              // Si es el primer endpoint que se carga exitosamente, ocultar spinner
              if (loadedCount === 1) {
                setLoading(false);
              }
            } else {
              console.warn(`⚠️ Respuesta con error para ${endpoint.url}:`, result.data.error);
              endpoint.setter([]);
              hasError = true;
              errorMessage = result.data.error || 'Error al obtener datos';
            }
          } else {
            console.error(`❌ Error en ${endpoint.url}:`, result.error);
            endpoint.setter([]);
            hasError = true;
            errorMessage = result.error;
          }
        } catch (err) {
          console.error(`❌ Error crítico en ${endpoint.url}:`, err);
          endpoint.setter([]);
          hasError = true;
          errorMessage = err.message;
        }
      }

      // Verificar errores de autenticación
      if (errorMessage.includes('401') || errorMessage.includes('token_expired')) {
        localStorage.removeItem('token');
        window.location.href = '/login';
        return;
      }

      if (hasError) {
        setError(errorMessage);
      }
      
      console.log('✅ Carga de datos completada');
    } catch (err) {
      console.error('Error crítico en fetchData:', err);
      
      if (err.message.includes('401') || err.message.includes('UNAUTHORIZED') || err.message.includes('token_expired')) {
        localStorage.removeItem('token');
        window.location.href = '/login';
        return;
      }
      
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  // Filter data by date range
  const filterDataByDateRange = (data) => {
    let filteredData = data;
    
    // Filter by date range
    if (dateRange !== 'all') {
      const now = new Date();
      filteredData = filteredData.filter(item => {
        const itemDate = new Date(item[1]);
        const daysDiff = Math.floor((now - itemDate) / (1000 * 60 * 60 * 24));
        
        switch (dateRange) {
          case 'last7days':
            return daysDiff <= 7;
          case 'last14days':
            return daysDiff <= 14;
          case 'last30days':
            return daysDiff <= 30;
          default:
            return true;
        }
      });
    }
    
    // Filter by user ID
    if (selectedUserId !== 'all') {
      filteredData = filteredData.filter(item => item[0] === parseInt(selectedUserId));
    }
    
    return filteredData;
  };

  // Process data for charts only (no stats calculation)
  const processChartData = () => {
    if (!monitoreoData.length) return { lineData: null, barData: null, processedData: null };

    // Filter data based on selected date range
    const filteredData = filterDataByDateRange(monitoreoData);
    if (!filteredData.length) return { lineData: null, barData: null, processedData: null };

    // Convert array data to objects with named properties
    const processedData = filteredData.map(item => ({
      id_usuario: item[0],
      fecha: item[1],
      id_postura: item[2],
      id_dispositivo: item[3],
      bp_sistolica_promedio: item[4],
      bp_sistolica_min: item[5],
      bp_sistolica_max: item[6],
      bp_diastolica_promedio: item[7],
      bp_diastolica_min: item[8],
      bp_diastolica_max: item[9]
    }));

    // Group by date for line chart
    const dateGroups = {};
    processedData.forEach(item => {
      const date = new Date(item.fecha).toLocaleDateString();
      if (!dateGroups[date]) {
        dateGroups[date] = {
          fecha: date,
          sistolica_promedio: 0,
          diastolica_promedio: 0,
          count: 0
        };
      }
      dateGroups[date].sistolica_promedio += item.bp_sistolica_promedio || 0;
      dateGroups[date].diastolica_promedio += item.bp_diastolica_promedio || 0;
      dateGroups[date].count += 1;
    });

    // Calculate averages
    Object.values(dateGroups).forEach(group => {
      group.sistolica_promedio = group.sistolica_promedio / group.count;
      group.diastolica_promedio = group.diastolica_promedio / group.count;
    });

    const sortedDates = Object.values(dateGroups).sort((a, b) => 
      new Date(b.fecha) - new Date(a.fecha) // Orden descendente (más recientes primero)
    );

    // Limitar a máximo 30 días para gráficos de barras (más legible)
    const maxDays = 30;
    let limitedDates;
    
    if (sortedDates.length <= maxDays) {
      // Si hay 30 días o menos, mostrar todos
      limitedDates = sortedDates;
    } else {
      // Si hay más de 30 días, tomar los primeros 30 días (más recientes)
      // Esto asegura mostrar los datos más recientes disponibles
      limitedDates = sortedDates.slice(0, maxDays);
    }

    // Line chart data
    const lineData = {
      labels: limitedDates.map(d => d.fecha),
      datasets: [
        {
          label: 'PA Sistólica Promedio',
          data: limitedDates.map(d => d.sistolica_promedio),
          borderColor: '#FF6B6B',
          backgroundColor: 'rgba(255, 107, 107, 0.1)',
          tension: 0.1
        },
        {
          label: 'PA Diastólica Promedio',
          data: limitedDates.map(d => d.diastolica_promedio),
          borderColor: '#4ECDC4',
          backgroundColor: 'rgba(78, 205, 196, 0.1)',
          tension: 0.1
        }
      ]
    };

    // Bar chart data - min/max comparison
    const barData = {
      labels: limitedDates.map(d => d.fecha),
      datasets: [
        {
          label: 'PA Sistólica Mín',
          data: limitedDates.map(d => {
            const dayData = processedData.filter(item => 
              new Date(item.fecha).toLocaleDateString() === d.fecha
            );
            return Math.min(...dayData.map(item => item.bp_sistolica_min || 0));
          }),
          backgroundColor: '#9DB3C1'
        },
        {
          label: 'PA Sistólica Máx',
          data: limitedDates.map(d => {
            const dayData = processedData.filter(item => 
              new Date(item.fecha).toLocaleDateString() === d.fecha
            );
            return Math.max(...dayData.map(item => item.bp_sistolica_max || 0));
          }),
          backgroundColor: '#FF6B6B'
        },
        {
          label: 'PA Diastólica Mín',
          data: limitedDates.map(d => {
            const dayData = processedData.filter(item => 
              new Date(item.fecha).toLocaleDateString() === d.fecha
            );
            return Math.min(...dayData.map(item => item.bp_diastolica_min || 0));
          }),
          backgroundColor: '#4ECDC4'
        },
        {
          label: 'PA Diastólica Máx',
          data: limitedDates.map(d => {
            const dayData = processedData.filter(item => 
              new Date(item.fecha).toLocaleDateString() === d.fecha
            );
            return Math.max(...dayData.map(item => item.bp_diastolica_max || 0));
          }),
          backgroundColor: '#FFA07A'
        }
      ]
    };

    return { lineData, barData, processedData, limitedDates, sortedDates };
  };

  const { lineData, barData, processedData, limitedDates, sortedDates } = processChartData();
  
  // Process signos vitales data for charts
  const processSignosVitalesChartData = () => {
    if (!signosVitalesData.length) return { lineData: null, barData: null, processedData: null };

    // Filter data based on selected date range
    const filteredData = filterDataByDateRange(signosVitalesData);
    if (!filteredData.length) return { lineData: null, barData: null, processedData: null };

    // Debug: Log the data structure
    console.log('Signos Vitales Data:', signosVitalesData);
    console.log('First item structure:', signosVitalesData[0]);
    console.log('Filtered Data:', filteredData);

    // Convert array data to objects with named properties
    const processedData = filteredData.map(item => {
      console.log('Processing item:', item);
      return {
        id_usuario: item[0],
        fecha: item[1], // fecha_registro
        id_postura: item[2],
        frecuencia_cardiaca_promedio_diario: item[3] || 0,
        saturacion_oxigeno_promedio_diario: item[4] || 0,
        mediciones_hr_dia: item[5] || 0,
        mediciones_spo2_dia: item[6] || 0
      };
    });

    // Group by date for line chart
    const dateGroups = {};
    processedData.forEach(item => {
      const date = new Date(item.fecha).toLocaleDateString();
      if (!dateGroups[date]) {
        dateGroups[date] = {
          fecha: date,
          frecuencia_cardiaca_promedio_diario: 0,
          saturacion_oxigeno_promedio_diario: 0,
          total_mediciones_hr: 0,
          total_mediciones_spo2: 0,
          count: 0
        };
      }
      dateGroups[date].frecuencia_cardiaca_promedio_diario += item.frecuencia_cardiaca_promedio_diario || 0;
      dateGroups[date].saturacion_oxigeno_promedio_diario += item.saturacion_oxigeno_promedio_diario || 0;
      dateGroups[date].total_mediciones_hr += item.mediciones_hr_dia || 0;
      dateGroups[date].total_mediciones_spo2 += item.mediciones_spo2_dia || 0;
      dateGroups[date].count += 1;
    });

    // Calculate averages
    Object.values(dateGroups).forEach(group => {
      group.frecuencia_cardiaca_promedio_diario = group.frecuencia_cardiaca_promedio_diario / group.count;
      group.saturacion_oxigeno_promedio_diario = group.saturacion_oxigeno_promedio_diario / group.count;
    });

    console.log('Date Groups:', dateGroups);

    const sortedDates = Object.values(dateGroups).sort((a, b) => 
      new Date(b.fecha) - new Date(a.fecha)
    );

    console.log('Sorted Dates:', sortedDates);

    // Limit to maximum 30 days for bar charts
    const maxDays = 30;
    let limitedDates;
    
    if (sortedDates.length <= maxDays) {
      limitedDates = sortedDates;
    } else {
      limitedDates = sortedDates.slice(0, maxDays);
    }

    // Line chart data - Evolución temporal de signos vitales
    const lineData = {
      labels: limitedDates.map(d => d.fecha),
      datasets: [
        {
          label: 'Frecuencia Cardíaca Promedio Diario (bpm)',
          data: limitedDates.map(d => d.frecuencia_cardiaca_promedio_diario),
          borderColor: '#FF6B6B',
          backgroundColor: 'rgba(255, 107, 107, 0.1)',
          tension: 0.3,
          yAxisID: 'y'
        },
        {
          label: 'Saturación Oxígeno Promedio Diario (%)',
          data: limitedDates.map(d => d.saturacion_oxigeno_promedio_diario),
          borderColor: '#45B7D1',
          backgroundColor: 'rgba(69, 183, 209, 0.1)',
          tension: 0.3,
          yAxisID: 'y1'
        }
      ]
    };

    // Bar chart data - Comparación de valores
    const barData = {
      labels: limitedDates.map(d => d.fecha),
      datasets: [
        {
          label: 'Frecuencia Cardíaca Promedio Diario',
          data: limitedDates.map(d => d.frecuencia_cardiaca_promedio_diario),
          backgroundColor: '#FF6B6B',
          yAxisID: 'y'
        },
        {
          label: 'Saturación Oxígeno Promedio Diario',
          data: limitedDates.map(d => d.saturacion_oxigeno_promedio_diario),
          backgroundColor: '#45B7D1',
          yAxisID: 'y1'
        }
      ]
    };

    console.log('Signos Vitales Line Data:', lineData);
    console.log('Signos Vitales Bar Data:', barData);
    console.log('Signos Vitales Limited Dates:', limitedDates);

    return { lineData, barData, processedData, limitedDates, sortedDates };
  };

  const { 
    lineData: signosLineData, 
    barData: signosBarData,
    processedData: signosProcessedData,
    limitedDates: signosLimitedDates,
    sortedDates: signosSortedDates
  } = processSignosVitalesChartData();

  // Process lab data for charts
  const processLabChartData = () => {
    if (!labChartsData || !labChartsData.length) return { lineData: null, barData: null, pieData: null };

    // Filter lab data based on selected date range, user, and analito
    let filteredData = labChartsData;
    
    // Filter by date range
    if (dateRange !== 'all') {
      const now = new Date();
      filteredData = filteredData.filter(item => {
        const itemDate = new Date(item.fecha);
        const daysDiff = Math.floor((now - itemDate) / (1000 * 60 * 60 * 24));
        
        switch (dateRange) {
          case 'last7days':
            return daysDiff <= 7;
          case 'last14days':
            return daysDiff <= 14;
          case 'last30days':
            return daysDiff <= 30;
          default:
            return true;
        }
      });
    }
    
    // Filter by user
    if (selectedUserId !== 'all') {
      filteredData = filteredData.filter(item => item.id_usuario === parseInt(selectedUserId));
    }
    
    // Filter by analito
    if (filterAnalito) {
      filteredData = filteredData.filter(item => item.analito === filterAnalito);
    }
    
    if (!filteredData.length) return { lineData: null, barData: null, pieData: null };

    // BMI distribution (since all data is from same date)
    const bmiData = filteredData.filter(item => item.analito === 'bmi' && item.valor_promedio);
    
    // Create BMI ranges for better visualization
    const bmiRanges = {
      'Bajo peso (<18.5)': 0,
      'Normal (18.5-24.9)': 0,
      'Sobrepeso (25-29.9)': 0,
      'Obesidad I (30-34.9)': 0,
      'Obesidad II (35-39.9)': 0,
      'Obesidad III (≥40)': 0
    };

    bmiData.forEach(item => {
      const bmi = item.valor_promedio;
      if (bmi < 18.5) bmiRanges['Bajo peso (<18.5)']++;
      else if (bmi >= 18.5 && bmi < 25) bmiRanges['Normal (18.5-24.9)']++;
      else if (bmi >= 25 && bmi < 30) bmiRanges['Sobrepeso (25-29.9)']++;
      else if (bmi >= 30 && bmi < 35) bmiRanges['Obesidad I (30-34.9)']++;
      else if (bmi >= 35 && bmi < 40) bmiRanges['Obesidad II (35-39.9)']++;
      else if (bmi >= 40) bmiRanges['Obesidad III (≥40)']++;
    });

    // Bar chart for BMI distribution with interactive legend
    const lineData = {
      labels: ['Distribución de BMI'],
      datasets: [
        {
          label: 'Bajo peso (<18.5)',
          data: [bmiRanges['Bajo peso (<18.5)']],
          backgroundColor: '#4ECDC4',
          borderColor: '#4ECDC4',
          borderWidth: 2,
          borderRadius: 4,
          borderSkipped: false
        },
        {
          label: 'Normal (18.5-24.9)',
          data: [bmiRanges['Normal (18.5-24.9)']],
          backgroundColor: '#96CEB4',
          borderColor: '#96CEB4',
          borderWidth: 2,
          borderRadius: 4,
          borderSkipped: false
        },
        {
          label: 'Sobrepeso (25-29.9)',
          data: [bmiRanges['Sobrepeso (25-29.9)']],
          backgroundColor: '#FF6B6B',
          borderColor: '#FF6B6B',
          borderWidth: 2,
          borderRadius: 4,
          borderSkipped: false
        },
        {
          label: 'Obesidad I (30-34.9)',
          data: [bmiRanges['Obesidad I (30-34.9)']],
          backgroundColor: '#45B7D1',
          borderColor: '#45B7D1',
          borderWidth: 2,
          borderRadius: 4,
          borderSkipped: false
        },
        {
          label: 'Obesidad II (35-39.9)',
          data: [bmiRanges['Obesidad II (35-39.9)']],
          backgroundColor: '#FF9800',
          borderColor: '#FF9800',
          borderWidth: 2,
          borderRadius: 4,
          borderSkipped: false
        },
        {
          label: 'Obesidad III (≥40)',
          data: [bmiRanges['Obesidad III (≥40)']],
          backgroundColor: '#F44336',
          borderColor: '#F44336',
          borderWidth: 2,
          borderRadius: 4,
          borderSkipped: false
        }
      ]
    };

    // Bar chart for pressure arterial distribution
    const presionData = filteredData.filter(item => item.analito === 'presión arterial');
    const presionCounts = {
      'Normal': 0,
      'Alta': 0,
      'Hypertension': 0,
      'Prehypertension': 0
    };
    
    presionData.forEach(item => {
      if (presionCounts.hasOwnProperty(item.valores_texto)) {
        presionCounts[item.valores_texto]++;
      }
    });

    const barData = {
      labels: ['Distribución de Presión Arterial'],
      datasets: [
        {
          label: 'Normal',
          data: [presionCounts['Normal'] || 0],
          backgroundColor: '#4ECDC4',
          borderColor: '#4ECDC4',
          borderWidth: 2,
          borderRadius: 4,
          borderSkipped: false
        },
        {
          label: 'Alta',
          data: [presionCounts['Alta'] || 0],
          backgroundColor: '#FF6B6B',
          borderColor: '#FF6B6B',
          borderWidth: 2,
          borderRadius: 4,
          borderSkipped: false
        },
        {
          label: 'Hypertension',
          data: [presionCounts['Hypertension'] || 0],
          backgroundColor: '#45B7D1',
          borderColor: '#45B7D1',
          borderWidth: 2,
          borderRadius: 4,
          borderSkipped: false
        },
        {
          label: 'Prehypertension',
          data: [presionCounts['Prehypertension'] || 0],
          backgroundColor: '#96CEB4',
          borderColor: '#96CEB4',
          borderWidth: 2,
          borderRadius: 4,
          borderSkipped: false
        }
      ]
    };

    // Pie chart for health conditions
    // Debug: ver qué valores tienen los datos
    const colesterolData = filteredData.filter(item => item.analito === 'colesterol alto');
    const problemasData = filteredData.filter(item => item.analito === 'problemas_corazon');
    const acvData = filteredData.filter(item => item.analito === 'acv');
    
    console.log('Colesterol alto - primeros 5:', colesterolData.slice(0, 5));
    console.log('Problemas corazón - primeros 5:', problemasData.slice(0, 5));
    console.log('ACV - primeros 5:', acvData.slice(0, 5));
    
    // Ver valores únicos
    const colesterolValues = [...new Set(colesterolData.map(item => item.valores_texto))];
    const problemasValues = [...new Set(problemasData.map(item => item.valores_texto))];
    const acvValues = [...new Set(acvData.map(item => item.valores_texto))];
    
    console.log('Valores únicos colesterol:', colesterolValues);
    console.log('Valores únicos problemas:', problemasValues);
    console.log('Valores únicos ACV:', acvValues);
    
    const healthConditions = {
      'Colesterol Alto': filteredData.filter(item => item.analito === 'colesterol alto' && item.valores_texto === 'True').length,
      'Problemas Cardíacos': filteredData.filter(item => item.analito === 'problemas_corazon' && item.valores_texto === 'True').length,
      'ACV': filteredData.filter(item => item.analito === 'acv' && item.valores_texto === 'True').length
    };

    const pieData = {
      labels: Object.keys(healthConditions),
      datasets: [
        {
          data: Object.values(healthConditions),
          backgroundColor: [
            '#FF6B6B', // Colesterol Alto - Rojo coral
            '#4ECDC4', // Problemas Cardíacos - Verde azulado
            '#45B7D1'  // ACV - Azul
          ],
          borderColor: [
            '#FF6B6B',
            '#4ECDC4',
            '#45B7D1'
          ],
          borderWidth: 2
        }
      ]
    };

    return { lineData, barData, pieData, filteredData };
  };

  const { 
    lineData: labLineData, 
    barData: labBarData,
    pieData: labPieData,
    filteredData: labFilteredData
  } = processLabChartData();
  
  // Get unique user IDs for filter dropdown
  const uniqueUserIds = [...new Set(monitoreoData.map(item => item[0]))].sort((a, b) => a - b);
  const uniqueSignosUserIds = [...new Set(signosVitalesData.map(item => item[0]))].sort((a, b) => a - b);

  if (loading) {
    return (
      <div className="admin-dashboard">
        <div className="dashboard-header">
          <h1>Reportes y Análisis</h1>
        </div>
        <LoadingSpinner 
          message="Cargando datos de reportes y análisis..."
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
          <h1>Reportes y Análisis</h1>
        </div>
        <ErrorDisplay
          title="Error al cargar los datos"
          message={error}
          type="network"
          onRetry={fetchData}
          showRetry={true}
        />
      </div>
    );
  }

  return (
    <div className="admin-dashboard">
      <div className="dashboard-header">
        <h1>Reportes y Análisis</h1>
        <div className="section-selector">
          <label htmlFor="sectionSelect">Sección:</label>
          <select 
            id="sectionSelect" 
            value={activeSection} 
            onChange={(e) => setActiveSection(e.target.value)}
            style={{ marginLeft: '10px', padding: '5px 10px' }}
          >
            <option value="monitoreo-pa">Monitoreo PA</option>
            <option value="signos-vitales">Signos Vitales</option>
            <option value="laboratorio">Laboratorio</option>
            <option value="estilo-vida">Estilo de Vida</option>
          </select>
        </div>
      </div>

      {activeSection === 'monitoreo-pa' && (
        <div className="table-card" id="monitoreo-pa-section">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <h4>Monitoreo PA</h4>
            <ExportButtons 
              sectionName="monitoreo-pa" 
              sectionId="monitoreo-pa-section" 
              data={processedData} 
            />
          </div>
          
          <div className="filters-container">
            <div className="date-filter">
              <label htmlFor="dateRange">Filtrar por período:</label>
              <select 
                id="dateRange" 
                value={dateRange} 
                onChange={(e) => setDateRange(e.target.value)}
              >
                <option value="all">Todas las fechas</option>
                <option value="last7days">Últimos 7 días</option>
                <option value="last14days">Últimos 14 días</option>
                <option value="last30days">Últimos 30 días</option>
              </select>
            </div>
            
            <div className="user-filter">
              <label htmlFor="userId">Filtrar por usuario:</label>
              <select 
                id="userId" 
                value={selectedUserId} 
                onChange={(e) => setSelectedUserId(e.target.value)}
              >
                <option value="all">Todos los usuarios</option>
                {uniqueUserIds.map(userId => (
                  <option key={userId} value={userId}>Usuario {userId}</option>
                ))}
              </select>
            </div>
          </div>
          
        {stats && (
          <div className="overview-cards">
            <div className="kpi-card">
              <h4>Total Registros</h4>
              <p>{stats.totalRegistros}</p>
            </div>
            <div className="kpi-card">
              <h4>PA Sistólica Promedio</h4>
              <p>{stats.sistolicaPromedio} <BloodPressureBadge systolic={stats.sistolicaPromedio} diastolic={0} /></p>
            </div>
            <div className="kpi-card">
              <h4>PA Diastólica Promedio</h4>
              <p>{stats.diastolicaPromedio} <BloodPressureBadge systolic={0} diastolic={stats.diastolicaPromedio} /></p>
            </div>
            <div className="kpi-card">
              <h4>Rango Sistólica</h4>
              <p>{stats.sistolicaMin} - {stats.sistolicaMax}</p>
            </div>
          </div>
        )}

          {lineData && barData && (
            <div className="charts-container">
              {sortedDates.length > 30 && (
                <div className="chart-notice">
                  <small>⚠️ Mostrando los últimos 30 días de {sortedDates.length} días disponibles para mantener legibilidad</small>
                </div>
              )}
              <div className="chart-card">
                <h4>Tendencia de Presión Arterial</h4>
                <Line 
                  data={lineData} 
                  options={{ 
                    responsive: true, 
                    plugins: { 
                      legend: { display: true },
                      title: { display: true, text: 'Evolución temporal de PA' }
                    },
                    scales: {
                      y: {
                        beginAtZero: false,
                        title: { display: true, text: 'mmHg' }
                      }
                    }
                  }} 
                />
              </div>
            <div className="chart-card">
              <h4>Variación Diaria (Mín/Máx)</h4>
              <Bar 
                data={barData} 
                options={{ 
                  responsive: true, 
                  plugins: { 
                    legend: { display: true },
                    title: { display: true, text: 'Rango de variación diaria' }
                  },
                  scales: {
                    y: {
                      beginAtZero: true,
                      title: { display: true, text: 'mmHg' }
                    }
                  }
                }} 
              />
            </div>
            </div>
          )}

          <div className="data-section">
            <h4>Datos Detallados</h4>
            <div className="data-container">
              {processedData && processedData.length > 0 ? (
                processedData.map((item, index) => (
                  <CollapsibleCard key={index} title={`Registro ${index + 1} - ${new Date(item.fecha).toLocaleDateString('es-ES')}`}>
                    <div className="data-grid">
                      <div className="data-item">
                        <strong>Usuario ID:</strong> {item.id_usuario}
                      </div>
                      <div className="data-item">
                        <strong>Fecha:</strong> {new Date(item.fecha).toLocaleDateString()}
                      </div>
                      <div className="data-item">
                        <strong>Postura ID:</strong> {item.id_postura}
                      </div>
                      <div className="data-item">
                        <strong>Dispositivo ID:</strong> {item.id_dispositivo}
                      </div>
                      <div className="data-item">
                        <strong>PA Sistólica:</strong> 
                        <span> Promedio: {item.bp_sistolica_promedio?.toFixed(1) || 'N/A'} </span>
                        <span> Mín: {item.bp_sistolica_min?.toFixed(1) || 'N/A'} </span>
                        <span> Máx: {item.bp_sistolica_max?.toFixed(1) || 'N/A'} </span>
                        <BloodPressureBadge systolic={item.bp_sistolica_promedio} diastolic={0} />
                      </div>
                      <div className="data-item">
                        <strong>PA Diastólica:</strong> 
                        <span> Promedio: {item.bp_diastolica_promedio?.toFixed(1) || 'N/A'} </span>
                        <span> Mín: {item.bp_diastolica_min?.toFixed(1) || 'N/A'} </span>
                        <span> Máx: {item.bp_diastolica_max?.toFixed(1) || 'N/A'} </span>
                        <BloodPressureBadge systolic={0} diastolic={item.bp_diastolica_promedio} />
                      </div>
                    </div>
                  </CollapsibleCard>
                ))
              ) : (
                <div className="no-data">
                  <h3>No hay datos disponibles</h3>
                  <p>No se encontraron registros de monitoreo de presión arterial.</p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {activeSection === 'signos-vitales' && (
        <div className="table-card" id="signos-vitales-section">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <h4>Signos Vitales</h4>
            <ExportButtons 
              sectionName="signos-vitales" 
              sectionId="signos-vitales-section" 
              data={signosVitalesData} 
            />
          </div>
          
          <div className="filters-container">
            <div className="date-filter">
              <label htmlFor="dateRange">Filtrar por período:</label>
              <select 
                id="dateRange" 
                value={dateRange} 
                onChange={(e) => setDateRange(e.target.value)}
              >
                <option value="all">Todas las fechas</option>
                <option value="last7days">Últimos 7 días</option>
                <option value="last14days">Últimos 14 días</option>
                <option value="last30days">Últimos 30 días</option>
              </select>
            </div>
            
            <div className="user-filter">
              <label htmlFor="userId">Filtrar por usuario:</label>
              <select 
                id="userId" 
                value={selectedUserId} 
                onChange={(e) => setSelectedUserId(e.target.value)}
              >
                <option value="all">Todos los usuarios</option>
                {uniqueSignosUserIds.map(userId => (
                  <option key={userId} value={userId}>Usuario {userId}</option>
                ))}
              </select>
            </div>
          </div>
          
        {signosVitalesStats && (
          <div className="overview-cards">
            <div className="kpi-card">
              <h4>Total Registros</h4>
              <p>{signosVitalesStats.totalRegistros}</p>
            </div>
            <div className="kpi-card">
              <h4>FC Promedio</h4>
              <p>{signosVitalesStats.frecuenciaCardiacaPromedio} bpm <VitalSignsBadge type="frecuencia_cardiaca" value={signosVitalesStats.frecuenciaCardiacaPromedio} /></p>
            </div>
            <div className="kpi-card">
              <h4>SpO2 Promedio</h4>
              <p>{signosVitalesStats.saturacionOxigenoPromedio} % <VitalSignsBadge type="saturacion_oxigeno" value={signosVitalesStats.saturacionOxigenoPromedio} /></p>
            </div>
            <div className="kpi-card">
              <h4>Rango FC</h4>
              <p>{signosVitalesStats.frecuenciaCardiacaMin} - {signosVitalesStats.frecuenciaCardiacaMax} bpm</p>
            </div>
          </div>
        )}

          {signosLineData && signosBarData && (
            <div className="charts-container">
              {signosSortedDates.length > 30 && (
                <div className="chart-notice">
                  <small>⚠️ Mostrando los últimos 30 días de {signosSortedDates.length} días disponibles para mantener legibilidad</small>
                </div>
              )}
              <div className="chart-card">
                <h4>Evolución Temporal de Signos Vitales</h4>
                <Line 
                  data={signosLineData} 
                  options={{ 
                    responsive: true, 
                    plugins: { 
                      legend: { display: true },
                      title: { display: true, text: 'Tendencia de Signos Vitales en el Tiempo' }
                    },
                    scales: {
                      y: {
                        type: 'linear',
                        display: true,
                        position: 'left',
                        title: { display: true, text: 'Frecuencia Cardíaca (bpm)' },
                        min: 40,
                        max: 120
                      },
                      y1: {
                        type: 'linear',
                        display: true,
                        position: 'right',
                        title: { display: true, text: 'Saturación Oxígeno (%)' },
                        min: 90,
                        max: 100,
                        grid: { drawOnChartArea: false }
                      }
                    }
                  }} 
                />
              </div>
            <div className="chart-card">
              <h4>Comparación de Signos Vitales por Día</h4>
              <Bar 
                data={signosBarData} 
                options={{ 
                  responsive: true, 
                  plugins: { 
                    legend: { display: true },
                    title: { display: true, text: 'Frecuencia Cardíaca vs Saturación Oxígeno' }
                  },
                  scales: {
                    y: {
                      beginAtZero: false,
                      min: 40,
                      max: 120,
                      title: { display: true, text: 'Frecuencia Cardíaca (bpm)' }
                    },
                    y1: {
                      beginAtZero: false,
                      min: 90,
                      max: 100,
                      title: { display: true, text: 'Saturación Oxígeno (%)' },
                      position: 'right',
                      grid: { drawOnChartArea: false }
                    }
                  }
                }} 
              />
            </div>
            </div>
          )}

          <div className="data-section">
            <h4>Datos Detallados</h4>
            <div className="data-container">
              {signosProcessedData && signosProcessedData.length > 0 ? (
                signosProcessedData.map((item, index) => (
                  <CollapsibleCard key={index} title={`Registro ${index + 1} - ${new Date(item.fecha).toLocaleDateString('es-ES')}`}>
                    <div className="data-grid">
                      <div className="data-item">
                        <strong>Usuario ID:</strong> {item.id_usuario}
                      </div>
                      <div className="data-item">
                        <strong>Fecha:</strong> {new Date(item.fecha).toLocaleDateString()}
                      </div>
                      <div className="data-item">
                        <strong>Postura ID:</strong> {item.id_postura}
                      </div>
                      <div className="data-item">
                        <strong>Frecuencia Cardíaca Promedio Diario:</strong> {item.frecuencia_cardiaca_promedio_diario?.toFixed(1) || 'N/A'} bpm <VitalSignsBadge type="frecuencia_cardiaca" value={item.frecuencia_cardiaca_promedio_diario} />
                      </div>
                      <div className="data-item">
                        <strong>Saturación Oxígeno Promedio Diario:</strong> {item.saturacion_oxigeno_promedio_diario?.toFixed(1) || 'N/A'} % <VitalSignsBadge type="saturacion_oxigeno" value={item.saturacion_oxigeno_promedio_diario} />
                      </div>
                      <div className="data-item">
                        <strong>Mediciones HR del Día:</strong> {item.mediciones_hr_dia || 0}
                      </div>
                      <div className="data-item">
                        <strong>Mediciones SpO2 del Día:</strong> {item.mediciones_spo2_dia || 0}
                      </div>
                    </div>
                  </CollapsibleCard>
                ))
              ) : (
                <div className="no-data">
                  <h3>No hay datos disponibles</h3>
                  <p>No se encontraron registros de signos vitales.</p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {activeSection === 'laboratorio' && (
        <div className="table-card" id="laboratorio-section">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <h4>Laboratorio</h4>
            <ExportButtons 
              sectionName="laboratorio" 
              sectionId="laboratorio-section" 
              data={labFilteredData} 
            />
          </div>
          
          <div className="filters-container">
            <div className="date-filter">
              <label htmlFor="dateRange">Filtrar por período:</label>
              <select 
                id="dateRange" 
                value={dateRange} 
                onChange={(e) => setDateRange(e.target.value)}
              >
                <option value="all">Todas las fechas</option>
                <option value="last7days">Últimos 7 días</option>
                <option value="last14days">Últimos 14 días</option>
                <option value="last30days">Últimos 30 días</option>
              </select>
            </div>
            
            <div className="user-filter">
              <label htmlFor="userId">Filtrar por usuario:</label>
              <select 
                id="userId" 
                value={selectedUserId} 
                onChange={(e) => setSelectedUserId(e.target.value)}
              >
                <option value="all">Todos los usuarios</option>
                {[...new Set(labData.map(item => item[0]))].sort((a, b) => a - b).map(userId => (
                  <option key={userId} value={userId}>Usuario {userId}</option>
                ))}
              </select>
            </div>
            
            <div className="user-filter">
              <label htmlFor="analito">Filtrar por analito:</label>
              <select 
                id="analito" 
                value={filterAnalito} 
                onChange={(e) => setFilterAnalito(e.target.value)}
              >
                <option value="">Todos los analitos</option>
                <option value="bmi">BMI</option>
                <option value="colesterol">Colesterol</option>
                <option value="colesterol alto">Colesterol Alto</option>
                <option value="presión arterial">Presión Arterial</option>
                <option value="problemas_corazon">Problemas Corazón</option>
                <option value="acv">ACV</option>
              </select>
            </div>
          </div>
          
        {labStats && (
          <div className="overview-cards">
            <div className="kpi-card">
              <h4>Total Mediciones</h4>
              <p>{labStats.totalRegistros}</p>
            </div>
            <div className="kpi-card">
              <h4>BMI Promedio</h4>
              <p>{labStats.bmiPromedio}</p>
              <BMIBadge bmi={labStats.bmiPromedio} />
            </div>
            <div className="kpi-card">
              <h4>Presión Arterial Normal</h4>
              <p>{labStats.presionNormalCount || 0} casos</p>
            </div>
            <div className="kpi-card">
              <h4>Presión Arterial Alta</h4>
              <p>{labStats.presionAltaCount || 0} casos</p>
            </div>
            <div className="kpi-card">
              <h4>Hipertensión</h4>
              <p>{labStats.hipertensionCount || 0} casos</p>
            </div>
            <div className="kpi-card">
              <h4>Prehipertensión</h4>
              <p>{labStats.prehipertensionCount || 0} casos</p>
            </div>
            <div className="kpi-card">
              <h4>Colesterol Alto</h4>
              <p>{labStats.colesterolAltoCount} casos</p>
            </div>
            <div className="kpi-card">
              <h4>Problemas Cardíacos</h4>
              <p>{labStats.problemasCorazonCount} casos</p>
            </div>
            <div className="kpi-card">
              <h4>ACV</h4>
              <p>{labStats.acvCount || 0} casos</p>
            </div>
          </div>
        )}

        {/* Charts Section */}
        {labLineData && labBarData && labPieData && (
          <div className="charts-container">
            <div className="chart-card">
              <h4>Distribución del BMI</h4>
              <Bar 
                data={labLineData} 
                options={{
                  responsive: true,
                  plugins: {
                    legend: { display: true },
                    title: { display: true, text: 'Distribución de BMI por Categorías' }
                  },
                  scales: {
                    y: {
                      beginAtZero: true,
                      title: { display: true, text: 'Número de Pacientes' }
                    }
                  }
                }}
              />
            </div>
            
            <div className="chart-card">
              <h4>Distribución de Presión Arterial</h4>
              <Bar 
                data={labBarData} 
                options={{
                  responsive: true,
                  plugins: {
                    legend: { display: true },
                    title: { display: true, text: 'Casos por Tipo de Presión Arterial' }
                  },
                  scales: {
                    y: {
                      beginAtZero: true,
                      title: { display: true, text: 'Número de Casos' }
                    }
                  }
                }}
              />
            </div>
            
            <div className="chart-card">
              <h4>Condiciones de Salud</h4>
              <div style={{ height: '400px' }}>
                <Pie 
                  data={labPieData} 
                  options={{
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                      legend: { display: true, position: 'bottom' },
                      title: { display: true, text: 'Distribución de Condiciones de Salud' }
                    }
                  }}
                />
              </div>
            </div>
          </div>
        )}

          <div className="data-section">
            <h4>Datos Detallados</h4>
            <div className="data-container">
              {labData && labData.length > 0 ? (
                labData
                  .filter(item => {
                    // Filtro por analito
                    if (filterAnalito && item[2] !== filterAnalito) return false;
                    // Filtro por usuario
                    if (selectedUserId !== 'all' && item[0] !== parseInt(selectedUserId)) return false;
                    return true;
                  })
                  .map((item, index) => (
                  <CollapsibleCard key={index} title={`Usuario ${item[0]} - ${new Date(item[1]).toLocaleDateString('es-ES')} - ${item[2]} ${item[6] ? `(${item[6]})` : ''}`}>
                    <div className="data-grid">
                      <div className="data-item">
                        <strong>Usuario ID:</strong> {item[0]}
                      </div>
                      <div className="data-item">
                        <strong>Fecha:</strong> {new Date(item[1]).toLocaleDateString()}
                      </div>
                      <div className="data-item">
                        <strong>Analito:</strong> {item[2]}
                      </div>
                      {/* Mostrar valores numéricos solo si existen */}
                      {(item[3] || item[4] || item[5]) && (
                        <>
                          <div className="data-item">
                            <strong>Valor Mínimo:</strong> {item[3] && typeof item[3] === 'number' ? item[3].toFixed(2) : (item[3] || 'N/A')}
                          </div>
                          <div className="data-item">
                            <strong>Valor Máximo:</strong> {item[4] && typeof item[4] === 'number' ? item[4].toFixed(2) : (item[4] || 'N/A')}
                          </div>
                          <div className="data-item">
                            <strong>Valor Promedio:</strong> {item[5] && typeof item[5] === 'number' ? item[5].toFixed(2) : 'N/A'}
                          </div>
                        </>
                      )}
                      
                      {/* Mostrar valores de texto si existen */}
                      {item[6] && (
                        <div className="data-item">
                          <strong>Valor:</strong> {item[6]}
                        </div>
                      )}
                      
                      <div className="data-item">
                        <strong>Total Mediciones:</strong> {item[7]}
                      </div>
                    </div>
                  </CollapsibleCard>
                ))
              ) : (
                <div className="no-data">
                  <h3>No hay datos disponibles</h3>
                  <p>No se encontraron registros de laboratorio.</p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {activeSection === 'estilo-vida' && (
        <div className="table-card" id="estilo-vida-section">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <h4>Estilo de Vida</h4>
            <ExportButtons 
              sectionName="estilo-vida" 
              sectionId="estilo-vida-section" 
              data={estiloVidaData} 
            />
    </div>
          
          <div className="filters-container">
            <div className="date-filter">
              <label htmlFor="dateRange">Filtrar por período:</label>
              <select 
                id="dateRange" 
                value={dateRange} 
                onChange={(e) => setDateRange(e.target.value)}
              >
                <option value="all">Todas las fechas</option>
                <option value="last7days_ultima">Últimos 7 días (última respuesta)</option>
                <option value="last7days_primera">Últimos 7 días (primera respuesta)</option>
                <option value="last14days_ultima">Últimos 14 días (última respuesta)</option>
                <option value="last14days_primera">Últimos 14 días (primera respuesta)</option>
                <option value="last30days_ultima">Últimos 30 días (última respuesta)</option>
                <option value="last30days_primera">Últimos 30 días (primera respuesta)</option>
              </select>
            </div>
            
            <div className="user-filter">
              <label htmlFor="userId">Filtrar por usuario:</label>
              <select 
                id="userId" 
                value={selectedUserId} 
                onChange={(e) => setSelectedUserId(e.target.value)}
              >
                <option value="all">Todos los usuarios</option>
                {[...new Set(estiloVidaData.map(item => item[0]))].sort((a, b) => a - b).map(userId => (
                  <option key={userId} value={userId}>Usuario {userId}</option>
                ))}
              </select>
            </div>
            
            <div className="user-filter">
              <label htmlFor="questionId">Filtrar por pregunta:</label>
              <select 
                id="questionId" 
                value={selectedQuestion} 
                onChange={(e) => setSelectedQuestion(e.target.value)}
              >
                <option value="all">Todas las preguntas</option>
                {estiloVidaData && estiloVidaData.length > 0 && 
                  Array.from(new Set(estiloVidaData.map(item => `${item[1]}_${item[2]}`)))
                    .map(questionKey => {
                      const [id, question] = questionKey.split('_', 2);
                      return (
                        <option key={questionKey} value={questionKey}>{question}</option>
                      );
                    })
                }
              </select>
            </div>
          </div>
          
        {estiloVidaStats && (
          <div className="overview-cards">
            <div className="kpi-card">
              <h4>Total Respuestas</h4>
              <p>{estiloVidaStats.totalRespuestas}</p>
            </div>
            <div className="kpi-card">
              <h4>Preguntas Únicas</h4>
              <p>{estiloVidaStats.preguntasUnicas}</p>
            </div>
            <div className="kpi-card">
              <h4>Usuarios Únicos</h4>
              <p>{estiloVidaStats.usuariosUnicos}</p>
            </div>
            <div className="kpi-card">
              <h4>Participación Promedio</h4>
              <p>
                {estiloVidaStats.totalRespuestas > 0 && estiloVidaStats.usuariosUnicos > 0 ? Math.round(estiloVidaStats.totalRespuestas / estiloVidaStats.usuariosUnicos) : 0} respuestas/usuario
                <ParticipationBadge value={estiloVidaStats.totalRespuestas > 0 && estiloVidaStats.usuariosUnicos > 0 ? Math.round(estiloVidaStats.totalRespuestas / estiloVidaStats.usuariosUnicos) : 0} />
              </p>
            </div>
          </div>
        )}

        {/* Charts Section */}
        {estiloVidaChartsData && estiloVidaChartsData.processedData && (() => {
          // Aplicar filtros a los datos de gráficos
          let filteredChartData = estiloVidaChartsData.processedData;
          
          // Filter by date range (using specified date type)
          if (dateRange !== 'all') {
            const now = new Date();
            filteredChartData = filteredChartData.filter(item => {
              let itemDate;
              
              // Determine which date to use based on the filter
              if (dateRange.includes('_ultima')) {
                itemDate = new Date(item.ultima_respuesta);
              } else if (dateRange.includes('_primera')) {
                itemDate = new Date(item.primera_respuesta);
              } else {
                itemDate = new Date(item.ultima_respuesta); // default to ultima_respuesta
              }
              
              const daysDiff = Math.floor((now - itemDate) / (1000 * 60 * 60 * 24));
              
              switch (dateRange) {
                case 'last7days_ultima':
                case 'last7days_primera':
                  return daysDiff <= 7;
                case 'last14days_ultima':
                case 'last14days_primera':
                  return daysDiff <= 14;
                case 'last30days_ultima':
                case 'last30days_primera':
                  return daysDiff <= 30;
                default:
                  return true;
              }
            });
          }
          
          // Filter by user
          if (selectedUserId !== 'all') {
            filteredChartData = filteredChartData.filter(item => item.id_usuario === parseInt(selectedUserId));
          }
          
          // Filter by question
          if (selectedQuestion !== 'all') {
            filteredChartData = filteredChartData.filter(item => {
              const questionKey = `${item.id_pregunta}_${item.pregunta}`;
              return questionKey === selectedQuestion;
            });
          }
          
          if (filteredChartData.length === 0) {
            return (
              <div className="charts-container">
                <div className="chart-card">
                  <h4>No hay datos para mostrar</h4>
                  <p>No se encontraron datos que coincidan con los filtros seleccionados.</p>
                </div>
              </div>
            );
          }
          
          // Agrupar datos filtrados por pregunta
          const preguntaGroups = {};
          filteredChartData.forEach(item => {
            const preguntaKey = `${item.id_pregunta}_${item.pregunta}`;
            if (!preguntaGroups[preguntaKey]) {
              preguntaGroups[preguntaKey] = {
                pregunta: item.pregunta,
                unidad: item.unidad,
                respuestas_si: 0,
                respuestas_no: 0,
                promedio_numerico: 0,
                porcentaje_si: 0,
                count: 0
              };
            }
            preguntaGroups[preguntaKey].respuestas_si += item.respuestas_si;
            preguntaGroups[preguntaKey].respuestas_no += item.respuestas_no;
            preguntaGroups[preguntaKey].promedio_numerico += item.promedio_numerico;
            preguntaGroups[preguntaKey].porcentaje_si += item.porcentaje_si;
            preguntaGroups[preguntaKey].count += 1;
          });
          
          // Calcular promedios
          Object.values(preguntaGroups).forEach(group => {
            if (group.count > 0) {
              group.promedio_numerico = group.promedio_numerico / group.count;
              group.porcentaje_si = group.porcentaje_si / group.count;
            }
          });
          
          const sortedPreguntas = Object.values(preguntaGroups).sort((a, b) => a.pregunta.localeCompare(b.pregunta));
          
          // Datos para gráfico de barras - Promedios numéricos por pregunta
          const preguntasNumericas = sortedPreguntas.filter(p => p.unidad === "número" || p.unidad === "escala");
          const barData = {
            labels: preguntasNumericas.map(() => ""),
            datasets: preguntasNumericas.map((p, index) => ({
              label: p.pregunta,
              data: Array(preguntasNumericas.length).fill(0).map((_, i) => i === index ? p.promedio_numerico : 0),
              backgroundColor: ["#4ECDC4", "#FF6B6B", "#45B7D1", "#96CEB4", "#FFA726", "#66BB6A", "#AB47BC", "#26A69A"][index % 8]
            }))
          };
          
          // Datos para gráfico de pastel - Distribución por tipo de pregunta
          const tipoPreguntas = {};
          filteredChartData.forEach(item => {
            const tipo = item.unidad;
            if (!tipoPreguntas[tipo]) {
              tipoPreguntas[tipo] = 0;
            }
            tipoPreguntas[tipo] += 1;
          });
          
          const pieData = {
            labels: Object.keys(tipoPreguntas),
            datasets: [
              {
                data: Object.values(tipoPreguntas),
                backgroundColor: ["#4ECDC4", "#FF6B6B", "#45B7D1", "#96CEB4"],
                borderColor: ["#4ECDC4", "#FF6B6B", "#45B7D1", "#96CEB4"],
                borderWidth: 2
              }
            ]
          };
          
          return (
            <div className="charts-container">
              <div className="chart-card">
                <h4>Distribución de Valores Numéricos</h4>
                <div style={{ height: '400px' }}>
                  <Bar 
                    data={barData} 
                    options={{ 
                      responsive: true,
                      maintainAspectRatio: false,
                      plugins: { 
                        legend: { display: true },
                        title: { display: true, text: 'Distribución de Valores Numéricos por Pregunta' }
                      },
                      scales: {
                        x: {
                          title: { display: true, text: 'Preguntas' },
                          offset: true,
                          grid: {
                            display: false
                          }
                        },
                        y: {
                          beginAtZero: true,
                          title: { display: true, text: 'Valor Promedio' }
                        }
                      },
                      elements: {
                        bar: {
                          borderWidth: 0,
                          borderRadius: 4,
                          borderSkipped: false,
                        }
                      }
                    }} 
                  />
                </div>
              </div>
              
              <div className="chart-card">
                <h4>Distribución por Tipo de Pregunta</h4>
                <div style={{ height: '400px' }}>
                  <Pie 
                    data={pieData} 
                    options={{
                      responsive: true,
                      maintainAspectRatio: false,
                      plugins: {
                        legend: { display: true, position: 'bottom' },
                        title: { display: true, text: 'Distribución por Tipo de Pregunta' }
                      }
                    }}
                  />
                </div>
              </div>
            </div>
          );
        })()}

          <div className="data-section">
            <h4>Datos Detallados</h4>
            <div className="data-container">
              {estiloVidaData && estiloVidaData.length > 0 ? (
                estiloVidaData
                  .filter(item => {
                    // Filter by date range (using ultima_respuesta)
                    if (dateRange !== 'all') {
                      const now = new Date();
                      let itemDate;
                      
                      // Determine which date to use based on the filter
                      if (dateRange.includes('_ultima')) {
                        itemDate = new Date(item[6]); // ultima_respuesta
                      } else if (dateRange.includes('_primera')) {
                        itemDate = new Date(item[5]); // primera_respuesta
                      } else {
                        itemDate = new Date(item[6]); // default to ultima_respuesta
                      }
                      
                      const daysDiff = Math.floor((now - itemDate) / (1000 * 60 * 60 * 24));
                      
                      switch (dateRange) {
                        case 'last7days_ultima':
                        case 'last7days_primera':
                          return daysDiff <= 7;
                        case 'last14days_ultima':
                        case 'last14days_primera':
                          return daysDiff <= 14;
                        case 'last30days_ultima':
                        case 'last30days_primera':
                          return daysDiff <= 30;
                        default:
                          return true;
                      }
                    }
                    // Filter by user
                    if (selectedUserId !== 'all' && item[0] !== parseInt(selectedUserId)) return false;
                    // Filter by question
                    if (selectedQuestion !== 'all') {
                      const questionKey = `${item[1]}_${item[2]}`;
                      if (questionKey !== selectedQuestion) return false;
                    }
                    return true;
                  })
                  .map((item, index) => (
                  <CollapsibleCard key={index} title={`Usuario ${item[0]} - ${item[2]} (${item[3]})`}>
                    <div className="data-grid">
                      <div className="data-item">
                        <strong>Usuario ID:</strong> {item[0]}
                      </div>
                      <div className="data-item">
                        <strong>Pregunta:</strong> {item[2]}
                      </div>
                      <div className="data-item">
                        <strong>Unidad:</strong> {item[3]}
                      </div>
                      <div className="data-item">
                        <strong>Total Respuestas:</strong> {item[4] || 0}
                      </div>
                      <div className="data-item">
                        <strong>Primera Respuesta:</strong> {new Date(item[5]).toLocaleDateString('es-ES')}
                      </div>
                      <div className="data-item">
                        <strong>Última Respuesta:</strong> {new Date(item[6]).toLocaleDateString('es-ES')}
                      </div>
                      <div className="data-item">
                        <strong>Respuestas Sí:</strong> {item[7] || 0}
                      </div>
                      <div className="data-item">
                        <strong>Respuestas No:</strong> {item[8] || 0}
                      </div>
                      <div className="data-item">
                        <strong>Promedio Numérico:</strong> {item[9] ? parseFloat(item[9]).toFixed(2) : 'N/A'}
                      </div>
                      <div className="data-item">
                        <strong>Valor Mínimo:</strong> {item[10] ? parseFloat(item[10]).toFixed(2) : 'N/A'}
                      </div>
                      <div className="data-item">
                        <strong>Valor Máximo:</strong> {item[11] ? parseFloat(item[11]).toFixed(2) : 'N/A'}
                      </div>
                      <div className="data-item">
                        <strong>Valores Únicos:</strong> {item[12] || 'N/A'}
                      </div>
                      <div className="data-item">
                        <strong>Porcentaje Sí:</strong> {item[13] ? parseFloat(item[13]).toFixed(2) + '%' : 'N/A'}
                      </div>
                    </div>
                  </CollapsibleCard>
                  ))
              ) : (
                <div className="no-data">
                  <h3>No hay datos disponibles</h3>
                  <p>No se encontraron registros de estilo de vida.</p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
