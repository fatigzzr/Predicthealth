const API_URL = "http://localhost:5000/patients"; // your patient microservice

async function getPatients(token) {
  const res = await fetch(API_URL, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!res.ok) throw new Error("Failed to fetch patients");
  return res.json(); // returns array of patients
}

export default { getPatients };
