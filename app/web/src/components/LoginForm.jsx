import { useState } from "react";
import authService from "../services/authService";

function LoginForm({ onLoginSuccess }) {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    try {
      const result = await authService.login(username, password);
      if (result.token) {
        // Guardar token en localStorage
        localStorage.setItem('token', result.token);
        localStorage.setItem('user', JSON.stringify(result.user));
        onLoginSuccess(); // triggers fade to dashboard
      } else {
        setError("Invalid credentials");
      }
    } catch (err) {
      setError("Invalid credentials");
    }
  };

  return (
    <form onSubmit={handleSubmit} className="login-form">
      <h2 className="form-title">Login</h2>
      <input
        type="text"
        placeholder="Username"
        value={username}
        onChange={(e) => setUsername(e.target.value)}
        required
      />
      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        required
      />
      {error && <div className="error">{error}</div>}
      <div className="button-container">
        <button type="submit" className="login-button">Login</button>
    </div>

    </form>
  );
}

export default LoginForm;
