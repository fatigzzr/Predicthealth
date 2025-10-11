import { useState, useCallback } from 'react';
import retryService from '../services/retryService';

/**
 * Hook personalizado para manejar retry de operaciones
 * @param {Function} operation - Función que ejecuta la operación
 * @param {Object} retryConfig - Configuración de retry
 * @returns {Object} Estado y funciones de retry
 */
export const useRetry = (operation, retryConfig = {}) => {
  const [isRetrying, setIsRetrying] = useState(false);
  const [retryCount, setRetryCount] = useState(0);
  const [lastError, setLastError] = useState(null);

  const executeWithRetry = useCallback(async (...args) => {
    setIsRetrying(true);
    setLastError(null);
    setRetryCount(0);

    try {
      const result = await retryService.executeWithRetry(
        () => operation(...args),
        {
          maxRetries: 3,
          baseDelay: 1000,
          ...retryConfig,
          onRetry: (attempt, error) => {
            setRetryCount(attempt + 1);
            console.log(`Reintentando operación (intento ${attempt + 1})...`);
            if (retryConfig.onRetry) {
              retryConfig.onRetry(attempt, error);
            }
          }
        }
      );
      
      setIsRetrying(false);
      return result;
    } catch (error) {
      setLastError(error);
      setIsRetrying(false);
      throw error;
    }
  }, [operation, retryConfig]);

  const resetRetry = useCallback(() => {
    setIsRetrying(false);
    setRetryCount(0);
    setLastError(null);
  }, []);

  return {
    isRetrying,
    retryCount,
    lastError,
    executeWithRetry,
    resetRetry
  };
};

export default useRetry;
