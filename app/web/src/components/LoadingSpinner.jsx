import React from 'react';

/**
 * Componente de spinner de carga con diferentes variantes
 * @param {Object} props - Props del componente
 * @param {string} props.message - Mensaje a mostrar
 * @param {string} props.variant - Variante del spinner ('default', 'dots', 'pulse')
 * @param {string} props.size - Tamaño del spinner ('small', 'medium', 'large')
 * @param {string} props.className - Clase CSS adicional
 */
const LoadingSpinner = ({ 
  message = 'Cargando...', 
  variant = 'default', 
  size = 'medium',
  className = ''
}) => {
  const getSizeStyles = () => {
    const sizes = {
      small: { width: '20px', height: '20px', fontSize: '12px' },
      medium: { width: '40px', height: '40px', fontSize: '14px' },
      large: { width: '60px', height: '60px', fontSize: '16px' }
    };
    return sizes[size] || sizes.medium;
  };

  const getSpinnerStyles = () => {
    const sizeStyles = getSizeStyles();
    return {
      ...sizeStyles,
      border: '3px solid #f3f3f3',
      borderTop: '3px solid #4ECDC4',
      borderRadius: '50%',
      animation: 'spin 1s linear infinite',
      margin: '0 auto 10px'
    };
  };

  const getDotsStyles = () => {
    const sizeStyles = getSizeStyles();
    return {
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      gap: '4px',
      margin: '0 auto 10px'
    };
  };

  const getDotStyles = (delay) => {
    const sizeStyles = getSizeStyles();
    const dotSize = size === 'small' ? '6px' : size === 'large' ? '12px' : '8px';
    return {
      width: dotSize,
      height: dotSize,
      backgroundColor: '#4ECDC4',
      borderRadius: '50%',
      animation: `bounce 1.4s ease-in-out ${delay}s infinite both`
    };
  };

  const getPulseStyles = () => {
    const sizeStyles = getSizeStyles();
    return {
      ...sizeStyles,
      backgroundColor: '#4ECDC4',
      borderRadius: '50%',
      animation: 'pulse 1.5s ease-in-out infinite',
      margin: '0 auto 10px'
    };
  };

  const renderSpinner = () => {
    switch (variant) {
      case 'dots':
        return (
          <div style={getDotsStyles()}>
            <div style={getDotStyles(0)}></div>
            <div style={getDotStyles(0.1)}></div>
            <div style={getDotStyles(0.2)}></div>
          </div>
        );
      case 'pulse':
        return <div style={getPulseStyles()}></div>;
      default:
        return <div style={getSpinnerStyles()}></div>;
    }
  };

  return (
    <div className={`loading-container ${className}`} style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '20px',
      textAlign: 'center'
    }}>
      {renderSpinner()}
      <p style={{
        color: '#5B696F',
        fontSize: getSizeStyles().fontSize,
        margin: 0,
        fontWeight: '500'
      }}>
        {message}
      </p>
      
      <style jsx>{`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        
        @keyframes bounce {
          0%, 80%, 100% {
            transform: scale(0);
          }
          40% {
            transform: scale(1);
          }
        }
        
        @keyframes pulse {
          0% {
            transform: scale(0.95);
            opacity: 0.7;
          }
          70% {
            transform: scale(1);
            opacity: 1;
          }
          100% {
            transform: scale(0.95);
            opacity: 0.7;
          }
        }
      `}</style>
    </div>
  );
};

export default LoadingSpinner;
