class CircuitBreaker {
  constructor(options = {}) {
    this.failureThreshold = options.failureThreshold || 5;
    this.timeout = options.timeout || 5000;
    this.resetTimeout = options.resetTimeout || 60000;
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failureCount = 0;
    this.nextAttempt = Date.now();
    this.successThreshold = options.successThreshold || 2;
    this.successCount = 0;
  }

  async call(fn) {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is OPEN');
      } else {
        this.state = 'HALF_OPEN';
        this.successCount = 0;
      }
    }

    try {
      const result = await this.executeWithTimeout(fn);
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  async executeWithTimeout(fn) {
    const timeoutPromise = new Promise((_, reject) =>
      setTimeout(() => reject(new Error('Request timeout')), this.timeout)
    );

    return Promise.race([fn(), timeoutPromise]);
  }

  onSuccess() {
    this.failureCount = 0;

    if (this.state === 'HALF_OPEN') {
      this.successCount++;
      if (this.successCount >= this.successThreshold) {
        this.state = 'CLOSED';
      }
    }
  }

  onFailure() {
    this.failureCount++;

    if (this.failureCount >= this.failureThreshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.resetTimeout;
    }
  }

  getState() {
    return this.state;
  }
}

// API service with circuit breaker
class ApiService {
  constructor() {
    this.authCircuitBreaker = new CircuitBreaker({
      failureThreshold: 3,
      timeout: 5000,
      resetTimeout: 30000
    });

    this.usersCircuitBreaker = new CircuitBreaker({
      failureThreshold: 3,
      timeout: 5000,
      resetTimeout: 30000
    });

    this.todosCircuitBreaker = new CircuitBreaker({
      failureThreshold: 3,
      timeout: 5000,
      resetTimeout: 30000
    });
  }

  async callAuthAPI(endpoint, options = {}) {
    try {
      return await this.authCircuitBreaker.call(async () => {
        const response = await fetch(`${process.env.VUE_APP_AUTH_API_URL}${endpoint}`, {
          ...options,
          headers: {
            'Content-Type': 'application/json',
            ...options.headers
          }
        });

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        return response.json();
      });
    } catch (error) {
      console.error('Auth API call failed:', error);
      // Return fallback response
      return { error: 'Authentication service unavailable', fallback: true };
    }
  }

  async callUsersAPI(endpoint, options = {}) {
    try {
      return await this.usersCircuitBreaker.call(async () => {
        const response = await fetch(`${process.env.VUE_APP_USERS_API_URL}${endpoint}`, options);

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        return response.json();
      });
    } catch (error) {
      console.error('Users API call failed:', error);
      // Return cached data or fallback
      return { error: 'Users service unavailable', fallback: true };
    }
  }

  async callTodosAPI(endpoint, options = {}) {
    try {
      return await this.todosCircuitBreaker.call(async () => {
        const response = await fetch(`${process.env.VUE_APP_TODOS_API_URL}${endpoint}`, options);

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        return response.json();
      });
    } catch (error) {
      console.error('Todos API call failed:', error);
      // Return fallback response
      return { error: 'Todos service unavailable', fallback: true, todos: [] };
    }
  }

  getCircuitBreakerStatus() {
    return {
      auth: this.authCircuitBreaker.getState(),
      users: this.usersCircuitBreaker.getState(),
      todos: this.todosCircuitBreaker.getState()
    };
  }
}

export default new ApiService();
