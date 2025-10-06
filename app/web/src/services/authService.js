// services/authService.js
export async function login(email, contraseña) {
  const xmlData = `
    <login>
      <email>${email}</email>
      <contraseña>${contraseña}</contraseña>
    </login>
  `;
  const response = await fetch("http://localhost:8000/login", {
    method: "POST",
    headers: { "Content-Type": "application/xml" },
    body: xmlData,
  });

  const text = await response.text();
  const parser = new DOMParser();
  const xmlDoc = parser.parseFromString(text, "text/xml");
  const status = xmlDoc.getElementsByTagName("status")[0].textContent;
  const token = xmlDoc.getElementsByTagName("token")[0]?.textContent;

  if (status === "success" && token) {
    localStorage.setItem("jwt", token);  // store JWT for subsequent requests
    return true;
  }
  return false;
}

export async function logout() {
  localStorage.removeItem("jwt");
}

export async function checkSession() {
  const token = localStorage.getItem("jwt");
  return { loggedIn: !!token };
}
