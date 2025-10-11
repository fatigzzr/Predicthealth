import './styles.css';
import { useState, useEffect } from "react";
import LoginForm from "./components/LoginForm";
import AdminDashboard from "./components/AdminDashboard";
import DatabaseTables from "./components/DatabaseTables";
import ReportesAnalisis from "./components/ReportesAnalisis";
import KPIs from "./components/KPIs";
import authService from "./services/authService";

function App() {
  const [showLogin, setShowLogin] = useState(true);
  const [fade, setFade] = useState(false);     // initial false for fade-in
  const [initialized, setInitialized] = useState(false);
  const [currentView, setCurrentView] = useState("dashboard"); // "dashboard", "database", "reportes", or "kpis"

  // Check "session" on mount
  useEffect(() => {
    const verifySession = async () => {
      const token = localStorage.getItem('token');
      if (token) {
        try {
          await authService.me(token);
          setShowLogin(false); // Usuario autenticado
        } catch (error) {
          localStorage.removeItem('token');
          localStorage.removeItem('user');
          setShowLogin(true); // Token inválido
        }
      } else {
        setShowLogin(true); // No hay token
      }
      setTimeout(() => setFade(true), 50);      // small delay to trigger fade-in
      setInitialized(true);
    };
    verifySession();
  }, []);

  const handleLoginSuccess = async () => {
    setFade(false);
    setTimeout(() => {
      setShowLogin(false);
      // mount dashboard with fade=false, then trigger fade-in shortly after
      setTimeout(() => setFade(true), 50);
    }, 400);
  };

  const handleLogout = async () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    setFade(false);
    setTimeout(() => {
      setShowLogin(true);
      // mount login with fade=false, then trigger fade-in shortly after
      setTimeout(() => setFade(true), 50);
    }, 400);
  };

  if (!initialized) return null;                 // wait until session checked

  return (
    <div className="App">
      {showLogin ? (
        <div className={`fade-container ${fade ? "fade-in" : "fade-out"}`}>
          <div className="login-page">
            <LoginForm onLoginSuccess={handleLoginSuccess} />
          </div>
        </div>
      ) : (
        <>
          {/* Navigation and Log Out buttons */}
          <div className="top-controls">
            <div className="navigation-buttons">
              <button 
                className={`nav-button ${currentView === "dashboard" ? "active" : ""}`}
                onClick={() => setCurrentView("dashboard")}
              >
                Dashboard
              </button>
              <button 
                className={`nav-button ${currentView === "kpis" ? "active" : ""}`}
                onClick={() => setCurrentView("kpis")}
              >
                KPIs
              </button>
              <button 
                className={`nav-button ${currentView === "reportes" ? "active" : ""}`}
                onClick={() => setCurrentView("reportes")}
              >
                Reportes y Análisis
              </button>
              <button 
                className={`nav-button ${currentView === "database" ? "active" : ""}`}
                onClick={() => setCurrentView("database")}
              >
                Base de Datos
              </button>
            </div>
            <button className="logout-button" onClick={handleLogout}>
              Log Out
            </button>
          </div>

          <div className={`fade-container ${fade ? "fade-in" : "fade-out"} dashboard-fade`}>
            {currentView === "dashboard" ? <AdminDashboard /> : 
             currentView === "database" ? <DatabaseTables /> : 
             currentView === "reportes" ? <ReportesAnalisis /> :
             <KPIs />}
          </div>
        </>
      )}
    </div>
  );
}

export default App;