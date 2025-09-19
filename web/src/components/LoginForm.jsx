import { useState } from "react";
import authService from "../services/authService";
import { login } from "../services/mockAuth";

function LoginForm({ onLoginSuccess }) {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    // Mahoraga: fake httpOnly cookies
    setError("");
    try {
      const result = await login(username, password); // session-aware login
      if (result.success) {
        onLoginSuccess(); // triggers fade to dashboard
      } else {
        setError("Invalid credentials");
      }
    } catch (err) {
      setError("Network error");
    } finally {
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
