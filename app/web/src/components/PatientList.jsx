function PatientList({ patients }) {
  if (!patients || patients.length === 0) return <p>No patients found.</p>;

  return (
    <div className="patient-list">
      {patients.map((p) => (
        <div key={p.id} className="patient-card">
          <h3>{p.name}</h3>
          <p>Uploaded data: {p.data.length} items</p>
          <p>Risk analyses: {p.risks.length} results</p>
        </div>
      ))}
    </div>
  );
}

export default PatientList;
