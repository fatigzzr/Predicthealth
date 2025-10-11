import retryService from './retryService';

const API_BASE_URL = 'http://localhost:5001/api';

class EntityService {
  async getEntidades() {
    const token = localStorage.getItem('token');
    if (!token) {
      throw new Error('No authentication token found');
    }

    const result = await retryService.fetchJsonWithRetrySilent(
      `${API_BASE_URL}/entidades`,
      {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      },
      {
        maxRetries: 3,
        baseDelay: 1000,
        onRetry: (attempt, error) => {
          console.log(`Reintentando getEntidades (intento ${attempt + 1})...`);
        }
      }
    );

    if (!result.success) {
      if (result.finalError && result.finalError.status === 401) {
        // Token expirado o inválido
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        throw new Error('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      throw new Error(result.error);
    }

    return result.data;
  }

  async getEntidadData(entidadName) {
    const token = localStorage.getItem('token');
    if (!token) {
      throw new Error('No authentication token found');
    }

    const result = await retryService.fetchJsonWithRetrySilent(
      `${API_BASE_URL}/entidades/${entidadName}`,
      {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      },
      {
        maxRetries: 3,
        baseDelay: 1000,
        onRetry: (attempt, error) => {
          console.log(`Reintentando getEntidadData (intento ${attempt + 1})...`);
        }
      }
    );

    if (!result.success) {
      if (result.finalError && result.finalError.status === 401) {
        // Token expirado o inválido
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        throw new Error('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      throw new Error(result.error);
    }

    return result.data;
  }


  async createEntidadRecord(entidadName, recordData) {
    const token = localStorage.getItem('token');
    if (!token) {
      throw new Error('No authentication token found');
    }

    console.log('Creating record for:', entidadName, '-> URL:', `${API_BASE_URL}/entidades/${entidadName}`);
    
    const result = await retryService.fetchJsonWithRetrySilent(
      `${API_BASE_URL}/entidades/${entidadName}`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(recordData)
      },
      {
        maxRetries: 3,
        baseDelay: 1000,
        onRetry: (attempt, error) => {
          console.log(`Reintentando createEntidadRecord (intento ${attempt + 1})...`);
        }
      }
    );

    if (!result.success) {
      if (result.finalError && result.finalError.status === 401) {
        // Token expirado o inválido
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        throw new Error('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      throw new Error(result.error);
    }

    return result.data;
  }

  async getPkColumns(entidadName) {
    const token = localStorage.getItem('token');
    if (!token) {
      throw new Error('No authentication token found');
    }

    const result = await retryService.fetchJsonWithRetrySilent(
      `${API_BASE_URL}/entidades/${entidadName}/pk-columns`,
      {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      },
      {
        maxRetries: 3,
        baseDelay: 1000,
        onRetry: (attempt, error) => {
          console.log(`Reintentando getPkColumns (intento ${attempt + 1})...`);
        }
      }
    );

    if (!result.success) {
      if (result.finalError && result.finalError.status === 401) {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        throw new Error('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      throw new Error(result.error);
    }

    return result.data;
  }

  async deleteEntidadRecord(entidadName, rowOrId, columns) {
    const token = localStorage.getItem('token');
    if (!token) {
      throw new Error('No authentication token found');
    }

    try {
      // Descubrir columnas PK para soportar PK simple o compuesta
      const pkInfo = await this.getPkColumns(entidadName).catch(() => ({ pkColumns: [] }));
      const pkColumns = pkInfo.pkColumns || [];

      let url = '';
      if (pkColumns.length <= 1) {
        // PK simple: usar valor de la columna PK si existe, si no, primera columna
        let idValue = rowOrId;
        if (Array.isArray(columns) && Array.isArray(rowOrId)) {
          if (pkColumns.length === 1) {
            const idx = columns.indexOf(pkColumns[0]);
            if (idx >= 0) idValue = rowOrId[idx];
          } else {
            idValue = rowOrId[0];
          }
        }
        url = `${API_BASE_URL}/entidades/${encodeURIComponent(entidadName)}/${encodeURIComponent(idValue)}`;
      } else {
        // PK compuesta: construir query params ?pk_col=value para cada columna PK
        if (!Array.isArray(columns) || !Array.isArray(rowOrId)) {
          throw new Error('Se requieren columnas y fila para borrar por PK compuesta');
        }
        const params = new URLSearchParams();
        for (const col of pkColumns) {
          const idx = columns.indexOf(col);
          if (idx < 0) throw new Error(`No se encontró la columna PK ${col} en las columnas`);
          params.set(`pk_${col}`, String(rowOrId[idx]));
        }
        url = `${API_BASE_URL}/entidades/${encodeURIComponent(entidadName)}/0?${params.toString()}`;
      }

      const result = await retryService.fetchJsonWithRetrySilent(
        url,
        {
          method: 'DELETE',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        },
        {
          maxRetries: 3,
          baseDelay: 1000,
          onRetry: (attempt, error) => {
            console.log(`Reintentando deleteEntidadRecord (intento ${attempt + 1})...`);
          }
        }
      );

      if (!result.success) {
        if (result.finalError && result.finalError.status === 401) {
          localStorage.removeItem('token');
          localStorage.removeItem('user');
          throw new Error('Sesión expirada. Por favor, inicia sesión nuevamente.');
        }
        throw new Error(result.error);
      }

      return result.data;
    } catch (error) {
      if (error.name === 'TypeError' && error.message.includes('fetch')) {
        throw new Error('No se pudo conectar con el servicio. Intenta más tarde.');
      }
      throw error;
    }
  }

  async updateEntidadRecord(entidadName, columns, originalRow, editedRowObj) {
    const token = localStorage.getItem('token');
    if (!token) {
      throw new Error('No authentication token found');
    }

    // Descubrir columnas PK
    const pkInfo = await this.getPkColumns(entidadName).catch(() => ({ pkColumns: [] }));
    const pkColumns = pkInfo.pkColumns || [];

    // Construir payload solo con campos cambiados y distintos de PK
    const changes = {};
    for (const col of columns) {
      if (pkColumns.includes(col)) continue;
      const originalVal = Array.isArray(originalRow) ? originalRow[columns.indexOf(col)] : originalRow?.[col];
      const newVal = editedRowObj[col];
      if (newVal !== originalVal) {
        changes[col] = newVal;
      }
    }
    if (Object.keys(changes).length === 0) {
      return { success: true, updated: 0 };
    }

    // Construir URL para PK simple o compuesta
    let url = '';
    if (pkColumns.length <= 1) {
      // PK simple: usar valor de la columna PK si existe, si no, primera columna
      let idValue = null;
      if (pkColumns.length === 1) {
        const idx = columns.indexOf(pkColumns[0]);
        idValue = Array.isArray(originalRow) ? originalRow[idx] : originalRow?.[pkColumns[0]];
      } else {
        idValue = Array.isArray(originalRow) ? originalRow[0] : originalRow?.[columns[0]];
      }
      url = `${API_BASE_URL}/entidades/${encodeURIComponent(entidadName)}/${encodeURIComponent(idValue)}`;
    } else {
      // PK compuesta
      const params = new URLSearchParams();
      for (const col of pkColumns) {
        const idx = columns.indexOf(col);
        const val = Array.isArray(originalRow) ? originalRow[idx] : originalRow?.[col];
        params.set(`pk_${col}`, String(val));
      }
      url = `${API_BASE_URL}/entidades/${encodeURIComponent(entidadName)}/0?${params.toString()}`;
    }

    const result = await retryService.fetchJsonWithRetrySilent(
      url,
      {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(changes)
      },
      {
        maxRetries: 3,
        baseDelay: 1000,
        onRetry: (attempt, error) => {
          console.log(`Reintentando updateEntidadRecord (intento ${attempt + 1})...`);
        }
      }
    );

    if (!result.success) {
      if (result.finalError && result.finalError.status === 401) {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        throw new Error('Sesión expirada. Por favor, inicia sesión nuevamente.');
      }
      throw new Error(result.error);
    }

    return result.data;
  }
}

export default new EntityService();
