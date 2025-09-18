import './styles.css';
import { useState, useEffect } from "react";
import LoginForm from "./components/LoginForm";
import AdminDashboard from "./components/AdminDashboard";
import { login, logout as logoutApi, checkSession } from "./services/mockAuth";

function App() {
  const [showLogin, setShowLogin] = useState(true);
  const [fade, setFade] = useState(false);     // initial false for fade-in
  const [initialized, setInitialized] = useState(false);

  // Check “session” on mount
  useEffect(() => {
    const verifySession = async () => {
      const result = await checkSession();
      setShowLogin(!result.loggedIn);           // show login if not logged in
      setTimeout(() => setFade(true), 50);      // small delay to trigger fade-in
      setInitialized(true);
    };
    verifySession();
  }, []);

  const handleLoginSuccess = async () => {
    await login();                               // simulate setting httpOnly cookie
    setFade(false);
    setTimeout(() => {
      setShowLogin(false);
      // mount dashboard with fade=false, then trigger fade-in shortly after
      setTimeout(() => setFade(true), 50);
    }, 400);
  };

  const handleLogout = async () => {
    await logoutApi();                           // simulate clearing cookie
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
          {/* Log Out button floats outside the dashboard */}
          <button className="logout-button" onClick={handleLogout}>
            Log Out
          </button>

          <div className={`fade-container ${fade ? "fade-in" : "fade-out"} dashboard-fade`}>
            <AdminDashboard />
          </div>
        </>
      )}
    </div>
  );
}

export default App;