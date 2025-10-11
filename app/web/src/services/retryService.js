/**
 * Servicio de retry con backoff exponencial
 * Maneja automáticamente los reintentos de requests fallidos
 */

class RetryService {
  constructor() {
    this.defaultConfig = {
      maxRetries: 3,
      baseDelay: 1000, // 1 segundo
      maxDelay: 10000, // 10 segundos máximo
      backoffMultiplier: 2,
      retryableErrors: [
        'TypeError', // Network errors
        'Failed to fetch',
        'Load failed',
        'Network error',
        'No se pudo conectar con el servicio'
      ],
      retryableStatusCodes: [500, 502, 503, 504, 0] // 0 para network errors
    };
  }

  /**
   * Calcula el delay para el siguiente intento usando backoff exponencial
   * @param {number} attempt - Número del intento actual (0-based)
   * @param {Object} config - Configuración de retry
   * @returns {number} Delay en milisegundos
   */
  calculateDelay(attempt, config) {
    const delay = config.baseDelay * Math.pow(config.backoffMultiplier, attempt);
    return Math.min(delay, config.maxDelay);
  }

  /**
   * Determina si un error es retryable
   * @param {Error} error - Error a evaluar
   * @param {number} statusCode - Código de estado HTTP
   * @param {Object} config - Configuración de retry
   * @returns {boolean} True si el error es retryable
   */
  isRetryableError(error, statusCode, config) {
    // Verificar códigos de estado retryable
    if (config.retryableStatusCodes.includes(statusCode)) {
      return true;
    }

    // Verificar mensajes de error retryable
    const errorMessage = error.message || error.toString();
    return config.retryableErrors.some(retryableError => 
      errorMessage.includes(retryableError)
    );
  }

  /**
   * Ejecuta una función con retry automático
   * @param {Function} fn - Función a ejecutar
   * @param {Object} options - Opciones de retry
   * @returns {Promise} Promise que resuelve con el resultado
   */
  async executeWithRetry(fn, options = {}) {
    const config = { ...this.defaultConfig, ...options };
    let lastError;

    for (let attempt = 0; attempt <= config.maxRetries; attempt++) {
      try {
        const result = await fn();
        return result;
      } catch (error) {
        lastError = error;
        
        // Si es el último intento, lanzar el error
        if (attempt === config.maxRetries) {
          break;
        }

        // Extraer status code si está disponible
        const statusCode = error.status || error.statusCode || 0;
        
        // Verificar si el error es retryable
        if (!this.isRetryableError(error, statusCode, config)) {
          throw error;
        }

        // Calcular delay y esperar
        const delay = this.calculateDelay(attempt, config);
        console.log(`Intento ${attempt + 1} falló, reintentando en ${delay}ms...`, error.message);
        
        await this.sleep(delay);
      }
    }

    // Si llegamos aquí, todos los intentos fallaron
    throw lastError;
  }

  /**
   * Wrapper para fetch con retry automático
   * @param {string} url - URL a hacer fetch
   * @param {Object} options - Opciones de fetch
   * @param {Object} retryOptions - Opciones de retry
   * @returns {Promise<Response>} Response del fetch
   */
  async fetchWithRetry(url, options = {}, retryOptions = {}) {
    return this.executeWithRetry(async () => {
      const response = await fetch(url, options);
      
      // Si la respuesta no es ok, lanzar error con status code
      if (!response.ok) {
        const error = new Error(`HTTP ${response.status}: ${response.statusText}`);
        error.status = response.status;
        error.statusCode = response.status;
        throw error;
      }
      
      return response;
    }, retryOptions);
  }

  /**
   * Wrapper para requests JSON con retry automático
   * @param {string} url - URL del request
   * @param {Object} options - Opciones de fetch
   * @param {Object} retryOptions - Opciones de retry
   * @returns {Promise<Object>} JSON response
   */
  async fetchJsonWithRetry(url, options = {}, retryOptions = {}) {
    const response = await this.fetchWithRetry(url, options, retryOptions);
    return await response.json();
  }

  /**
   * Wrapper para requests JSON con retry automático que no lanza error hasta agotar intentos
   * @param {string} url - URL del request
   * @param {Object} options - Opciones de fetch
   * @param {Object} retryOptions - Opciones de retry
   * @returns {Promise<{success: boolean, data?: Object, error?: string, retryCount: number}>} Resultado del retry
   */
  async fetchJsonWithRetrySilent(url, options = {}, retryOptions = {}) {
    const config = { ...this.defaultConfig, ...retryOptions };
    let lastError;
    let retryCount = 0;

    for (let attempt = 0; attempt <= config.maxRetries; attempt++) {
      try {
        const response = await fetch(url, options);
        
        if (!response.ok) {
          const error = new Error(`HTTP ${response.status}: ${response.statusText}`);
          error.status = response.status;
          error.statusCode = response.status;
          throw error;
        }
        
        const data = await response.json();
        return { success: true, data, retryCount };
      } catch (error) {
        lastError = error;
        retryCount = attempt;
        
        // Si es el último intento, retornar error
        if (attempt === config.maxRetries) {
          break;
        }

        // Extraer status code si está disponible
        const statusCode = error.status || error.statusCode || 0;
        
        // Verificar si el error es retryable
        if (!this.isRetryableError(error, statusCode, config)) {
          return { success: false, error: error.message, retryCount };
        }

        // Calcular delay y esperar
        const delay = this.calculateDelay(attempt, config);
        console.log(`Intento ${attempt + 1} falló, reintentando en ${delay}ms...`, error.message);
        
        if (config.onRetry) {
          config.onRetry(attempt, error);
        }
        
        await this.sleep(delay);
      }
    }

    // Si llegamos aquí, todos los intentos fallaron
    return { 
      success: false, 
      error: lastError.message, 
      retryCount,
      finalError: lastError
    };
  }

  /**
   * Función de utilidad para dormir
   * @param {number} ms - Milisegundos a dormir
   * @returns {Promise} Promise que se resuelve después del delay
   */
  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Crea un wrapper para un servicio existente con retry automático
   * @param {Object} service - Servicio a envolver
   * @param {Object} retryOptions - Opciones de retry por defecto
   * @returns {Object} Servicio envuelto con retry
   */
  wrapService(service, retryOptions = {}) {
    const wrappedService = {};
    
    for (const [methodName, method] of Object.entries(service)) {
      if (typeof method === 'function') {
        wrappedService[methodName] = async (...args) => {
          return this.executeWithRetry(async () => {
            return await method.apply(service, args);
          }, retryOptions);
        };
      } else {
        wrappedService[methodName] = method;
      }
    }
    
    return wrappedService;
  }
}

// Crear instancia singleton
const retryService = new RetryService();

export default retryService;
