import React from 'react';

/**
 * Componente de botón de reintentar con estados visuales
 * @param {Object} props - Props del componente
 * @param {Function} props.onRetry - Función a ejecutar al hacer clic
 * @param {boolean} props.isRetrying - Si está en proceso de retry
 * @param {number} props.retryCount - Número de intentos realizados
 * @param {string} props.error - Mensaje de error
 * @param {string} props.className - Clase CSS adicional
 * @param {string} props.children - Texto del botón
 */
const RetryButton = ({ 
  onRetry, 
  isRetrying = false, 
  retryCount = 0, 
  error = null,
  className = '',
  children = 'Reintentar'
}) => {
  const handleClick = () => {
    if (!isRetrying && onRetry) {
      onRetry();
    }
  };

  const getButtonText = () => {
    if (isRetrying) {
      return `Reintentando... (${retryCount})`;
    }
    if (retryCount > 0) {
      return `Reintentar (${retryCount} intentos)`;
    }
    return children;
  };

  const getButtonStyle = () => {
    const baseStyle = {
      padding: '10px 20px',
      backgroundColor: isRetrying ? '#FFB3B3' : '#FF6B6B',
      color: '#FFFFFF',
      border: 'none',
      borderRadius: '6px',
      cursor: isRetrying ? 'not-allowed' : 'pointer',
      fontSize: '14px',
      fontWeight: '500',
      transition: 'all 0.3s ease',
      opacity: isRetrying ? 0.7 : 1,
      minWidth: '120px',
      boxShadow: isRetrying ? 'none' : '0 2px 4px rgba(255, 107, 107, 0.3)'
    };

    return baseStyle;
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '10px' }}>
      <button
        onClick={handleClick}
        disabled={isRetrying}
        className={`retry-button ${className}`}
        style={getButtonStyle()}
        onMouseOver={(e) => {
          if (!isRetrying) {
            e.target.style.backgroundColor = '#FF5252';
            e.target.style.transform = 'translateY(-1px)';
            e.target.style.boxShadow = '0 4px 8px rgba(255, 107, 107, 0.4)';
          }
        }}
        onMouseOut={(e) => {
          if (!isRetrying) {
            e.target.style.backgroundColor = '#FF6B6B';
            e.target.style.transform = 'translateY(0)';
            e.target.style.boxShadow = '0 2px 4px rgba(255, 107, 107, 0.3)';
          }
        }}
      >
        {getButtonText()}
      </button>
      
      {error && (
        <div style={{ 
          color: '#FF6B6B', 
          fontSize: '12px', 
          textAlign: 'center',
          maxWidth: '300px',
          wordWrap: 'break-word'
        }}>
          {error}
        </div>
      )}
      
      {isRetrying && (
        <div style={{ 
          color: '#45B7D1', 
          fontSize: '12px', 
          textAlign: 'center',
          fontStyle: 'italic'
        }}>
          Esperando respuesta del servidor...
        </div>
      )}
    </div>
  );
};

export default RetryButton;
