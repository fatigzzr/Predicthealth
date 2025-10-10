import React from 'react';
import RetryButton from './RetryButton';

/**
 * Componente para mostrar errores con diferentes tipos y acciones
 * @param {Object} props - Props del componente
 * @param {string} props.title - Título del error
 * @param {string} props.message - Mensaje de error
 * @param {string} props.type - Tipo de error ('network', 'auth', 'server', 'generic')
 * @param {Function} props.onRetry - Función a ejecutar al reintentar
 * @param {Function} props.onDismiss - Función a ejecutar al cerrar
 * @param {boolean} props.showRetry - Si mostrar botón de reintentar
 * @param {string} props.className - Clase CSS adicional
 */
const ErrorDisplay = ({ 
  title = 'Error',
  message,
  type = 'generic',
  onRetry,
  onDismiss,
  showRetry = true,
  className = ''
}) => {
  const getErrorIcon = () => {
    switch (type) {
      case 'network':
        return '🌐';
      case 'auth':
        return '🔐';
      case 'server':
        return '⚠️';
      default:
        return '❌';
    }
  };

  const getErrorColor = () => {
    switch (type) {
      case 'network':
        return '#FF6B6B';
      case 'auth':
        return '#FFA726';
      case 'server':
        return '#FF5722';
      default:
        return '#F44336';
    }
  };

  const getErrorTitle = () => {
    switch (type) {
      case 'network':
        return title || 'Error al cargar los datos';
      case 'auth':
        return title || 'Error de Autenticación';
      case 'server':
        return title || 'Error del Servidor';
      default:
        return title;
    }
  };

  const getErrorDescription = () => {
    switch (type) {
      case 'network':
        return message || 'Error al cargar los datos. Intenta nuevamente.';
      case 'auth':
        return message || 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
      case 'server':
        return message || 'El servidor está experimentando problemas. Intenta más tarde.';
      default:
        return message;
    }
  };

  const containerStyle = {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '40px 20px',
    textAlign: 'center',
    backgroundColor: '#1E2B38',
    borderRadius: '8px',
    border: `1px solid #ADC7EA`,
    maxWidth: '500px',
    margin: '0 auto',
    color: '#FFFFFF'
  };

  const iconStyle = {
    fontSize: '48px',
    marginBottom: '16px'
  };

  const titleStyle = {
    color: '#ADC7EA',
    fontSize: '24px',
    fontWeight: 'bold',
    marginBottom: '12px'
  };

  const messageStyle = {
    color: '#FFFFFF',
    fontSize: '16px',
    lineHeight: '1.5',
    marginBottom: '24px',
    maxWidth: '400px'
  };

  const actionsStyle = {
    display: 'flex',
    gap: '12px',
    flexWrap: 'wrap',
    justifyContent: 'center'
  };

  const dismissButtonStyle = {
    padding: '8px 16px',
    backgroundColor: 'transparent',
    color: '#ADC7EA',
    border: '1px solid #ADC7EA',
    borderRadius: '4px',
    cursor: 'pointer',
    fontSize: '14px',
    transition: 'all 0.3s ease'
  };

  return (
    <div className={`error-display ${className}`} style={containerStyle}>
      <div style={iconStyle}>
        {getErrorIcon()}
      </div>
      
      <h2 style={titleStyle}>
        {getErrorTitle()}
      </h2>
      
      <p style={messageStyle}>
        {getErrorDescription()}
      </p>
      
      <div style={actionsStyle}>
        {showRetry && onRetry && (
          <RetryButton 
            onRetry={onRetry}
            error={message}
          />
        )}
        
        {onDismiss && (
          <button
            onClick={onDismiss}
            style={dismissButtonStyle}
            onMouseOver={(e) => {
              e.target.style.backgroundColor = '#ADC7EA';
              e.target.style.color = '#1E2B38';
            }}
            onMouseOut={(e) => {
              e.target.style.backgroundColor = 'transparent';
              e.target.style.color = '#ADC7EA';
            }}
          >
            Cerrar
          </button>
        )}
      </div>
    </div>
  );
};

export default ErrorDisplay;
