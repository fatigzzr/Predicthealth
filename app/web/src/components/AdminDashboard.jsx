import { useState } from "react";
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from "recharts";
import '../styles.css';

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
        <h4>{title}</h4>
        <span>{open ? "▲" : "▼"}</span>
      </div>
      {open && <div className="card-body">{children}</div>}
    </div>
  );
}

// Conditional Badge
function RiskBadge({ value, type }) {
  let text = "Normal";
  let color = "#5B696F";

  if (type === "hba1c") {
    if (value >= 6.5) { text = "Alto riesgo"; color = "#FF6B6B"; }
    else if (value >= 5.7) { text = "Moderado"; color = "#FFD93D"; }
  }
  if (type === "bloodPressure") {
    if (value >= 140) { text = "Alto riesgo"; color = "#FF6B6B"; }
    else if (value >= 120) { text = "Moderado"; color = "#FFD93D"; }
  }
  if (type === "ldl") {
    if (value > 130) { text = "Alto riesgo"; color = "#FF6B6B"; }
    else if (value > 100) { text = "Moderado"; color = "#FFD93D"; }
  }

  return (
    <span style={{ backgroundColor: color, color: "#FFFFFF", padding: "2px 6px", borderRadius: "4px", marginLeft: "8px", fontSize: "0.8rem" }}>
      {text}
    </span>
  );
}

export default function AdminDashboard({ patients }) {
  // Mock patients
  const mockPatients = [
    {
      id: 1, name: "Juan Pérez", age: 45, sex: "Masculino", bmi: 27.4, diabetes: true, hypertension: false,
      personalInfo: { firstName: "Juan", lastName: "Pérez", dob: "1978-03-12", sex: "Masculino", age: 45 },
      lifestyle: { fruits: true, veggies: true, salt: 6, smoking: false, alcoholExcess: false, mobilityIssues: false, sleepHours: 7, stressLevel: 6, badMentalDays: 4, activityLevel: "moderado", exercise3xWeek: true, badPhysicalDays: 2 },
      documents: [
        { type: "HbA1c", date: "2025-08-12", value: 6.8 },
        { type: "PA promedio", date: "2025-08-14", systolic: 145, diastolic: 92 },
        { type: "Perfil Lipídico", date: "2025-08-14", ldl: 140, hdl: 50, triglycerides: 180 }
      ],
      predictions: [{ model: "Diabetes Risk Base", value: 7.2 }, { model: "Diabetes Risk Adjusted", value: 8.5 }]
    },
    {
      id: 2, name: "María Gómez", age: 52, sex: "Femenino", bmi: 24.5, diabetes: false, hypertension: true,
      personalInfo: { firstName: "María", lastName: "Gómez", dob: "1973-09-22", sex: "Femenino", age: 52 },
      lifestyle: { fruits: true, veggies: true, salt: 5, smoking: false, alcoholExcess: false, mobilityIssues: false, sleepHours: 6, stressLevel: 4, badMentalDays: 2, activityLevel: "alto", exercise3xWeek: true, badPhysicalDays: 1 },
      documents: [
        { type: "HbA1c", date: "2025-07-22", value: 5.4 },
        { type: "PA promedio", date: "2025-07-22", systolic: 135, diastolic: 85 },
        { type: "Perfil Lipídico", date: "2025-07-22", ldl: 110, hdl: 60, triglycerides: 150 }
      ],
      predictions: [{ model: "Diabetes Risk Base", value: 3.5 }, { model: "Diabetes Risk Adjusted", value: 3.2 }]
    }
  ];

  const [selectedPatientId, setSelectedPatientId] = useState(mockPatients[0].id);
  const p = mockPatients.find(pt => pt.id === selectedPatientId);

  const labData = [
    { name: "HbA1c", value: p.documents.find(d => d.type === "HbA1c")?.value || 0 },
    { name: "PA Sistólica", value: p.documents.find(d => d.type === "PA promedio")?.systolic || 0 },
    { name: "PA Diastólica", value: p.documents.find(d => d.type === "PA promedio")?.diastolic || 0 },
    { name: "LDL", value: p.documents.find(d => d.type === "Perfil Lipídico")?.ldl || 0 },
    { name: "HDL", value: p.documents.find(d => d.type === "Perfil Lipídico")?.hdl || 0 }
  ];

  const predictionData = p.predictions.map(pred => ({ name: pred.model, value: pred.value }));

  return (
    <div className="admin-dashboard">
      <div className="dashboard-header">
        <h1>{p.name} - Dashboard</h1>
        <select value={selectedPatientId} onChange={e => setSelectedPatientId(parseInt(e.target.value))}>
          {mockPatients.map(pt => <option key={pt.id} value={pt.id}>{pt.name}</option>)}
        </select>
      </div>

      {/* Overview KPIs with conditional badges */}
      <div className="overview-cards">
        <div className="kpi-card">
          <h4>BMI</h4>
          <p>{p.bmi}</p>
        </div>
        <div className="kpi-card">
          <h4>Diabetes</h4>
          <p>{p.diabetes ? "Sí" : "No"} <RiskBadge value={p.documents.find(d => d.type === "HbA1c")?.value} type="hba1c" /></p>
        </div>
        <div className="kpi-card">
          <h4>Hipertensión</h4>
          <p>{p.hypertension ? "Sí" : "No"} <RiskBadge value={p.documents.find(d => d.type === "PA promedio")?.systolic} type="bloodPressure" /></p>
        </div>
        <div className="kpi-card">
          <h4>LDL</h4>
          <p>{p.documents.find(d => d.type === "Perfil Lipídico")?.ldl} <RiskBadge value={p.documents.find(d => d.type === "Perfil Lipídico")?.ldl} type="ldl" /></p>
        </div>
      </div>

      {/* Charts */}
      <div className="charts-container">
        <div className="chart-card">
          <h4>Valores de Laboratorio</h4>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={labData}>
              <XAxis dataKey="name" stroke="#ADC7EA" />
              <YAxis stroke="#ADC7EA" />
              <Tooltip />
              <Bar dataKey="value" fill="#5B696F" />
            </BarChart>
          </ResponsiveContainer>
        </div>
        <div className="chart-card">
          <h4>Predicciones de Riesgo</h4>
          <ResponsiveContainer width="100%" height={150}>
            <BarChart data={predictionData}>
              <XAxis dataKey="name" stroke="#ADC7EA" />
              <YAxis stroke="#ADC7EA" />
              <Tooltip />
              <Bar dataKey="value" fill="#9DB3C1" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Tabbed detailed info */}
      <Tabs>
        <div label="Información Personal">
          <p>Nombre: {p.personalInfo.firstName} {p.personalInfo.lastName}</p>
          <p>Fecha de Nacimiento: {p.personalInfo.dob}</p>
          <p>Edad: {p.personalInfo.age}</p>
          <p>Sexo: {p.personalInfo.sex}</p>
        </div>

        <div label="Estilo de Vida" >
          {Object.entries(p.lifestyle).map(([key, value]) => (
            <p key={key}>{key}: {value.toString()}</p>
          ))}
        </div>

        <div label="Documentos Clínicos">
          {p.documents.map((doc, i) => (
            <CollapsibleCard key={i} title={`${doc.type} (${doc.date})`}>
              {doc.value !== undefined && <p>Valor: <RiskBadge value={doc.value} type="hba1c"/></p>}
              {doc.ldl !== undefined && <p>LDL: <RiskBadge value={doc.ldl} type="ldl"/></p>}
              {doc.hdl !== undefined && <p>HDL: {doc.hdl}</p>}
              {doc.triglycerides !== undefined && <p>Triglicéridos: {doc.triglycerides}</p>}
              {doc.systolic !== undefined && <p>PA Sistólica: <RiskBadge value={doc.systolic} type="bloodPressure"/></p>}
              {doc.diastolic !== undefined && <p>PA Diastólica: {doc.diastolic}</p>}
            </CollapsibleCard>
          ))}
        </div>

        <div label="Predicciones">
          {p.predictions.map((pred, i) => (
            <div key={i} className="card">
              <p>{pred.model}: {pred.value}</p>
            </div>
          ))}
        </div>
      </Tabs>
    </div>
  );
}
