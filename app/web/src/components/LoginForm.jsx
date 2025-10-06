// LoginForm.js
import { useState } from "react";
import { login } from "../services/authService";

function LoginForm({ onLoginSuccess }) {
  const [email, setEmail] = useState("");
  const [contraseña, setContraseña] = useState("");
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    const success = await login(email, contraseña);
    if (success) onLoginSuccess();
    else setError("Invalid credentials");
  };

  return (
    <form onSubmit={handleSubmit}>
      <input type="email" value={email} onChange={e => setEmail(e.target.value)} placeholder="Email" />
      <input type="password" value={contraseña} onChange={e => setContraseña(e.target.value)} placeholder="Contraseña" />
      <button type="submit">Login</button>
      {error && <p>{error}</p>}
    </form>
  );
}

export default LoginForm;
