const lambda = require('./index');
const { Pool } = require('pg');

// Mock del Pool
jest.mock('pg', () => {
  const mClient = {
    connect: jest.fn(),
    query: jest.fn(),
    release: jest.fn(),
  };
  return {
    Pool: jest.fn(() => mClient),
  };
});

describe('Lambda Function - loginUser', () => {
  let mockClient;

  beforeEach(() => {
    mockClient = new Pool();
  });

  test('should return 500 if no body is received', async () => {
    const result = await lambda.handler({});
    expect(result.statusCode).toBe(500);
    expect(JSON.parse(result.body).message).toBe("Error interno del servidor");
    expect(JSON.parse(result.body).error).toBe("No se recibió body en la petición");
  });

  test('should return 401 if invalid credentials are provided', async () => {
    mockClient.connect.mockResolvedValue(mockClient);
    mockClient.query.mockResolvedValue({ rows: [] });

    const event = {
      body: JSON.stringify({ username: 'miguel', password: 'wrongpass' }),
    };
    const result = await lambda.handler(event);

    expect(result.statusCode).toBe(401);
    expect(result.body).toContain('Credenciales inválidas');
  });

  test('should return 200 and user data if valid credentials are provided', async () => {
    const fakeUser = { id: 1, username: 'miguel' };

    mockClient.connect.mockResolvedValue(mockClient);
    mockClient.query.mockResolvedValue({ rows: [fakeUser] });

    const event = {
      body: JSON.stringify({ username: 'miguel', password: 'miguel1' }),
    };
    const result = await lambda.handler(event);

    expect(result.statusCode).toBe(200);
    expect(result.body).toContain('Login exitoso');
    expect(JSON.parse(result.body).user.username).toBe('miguel');
  });

  test('should handle database errors', async () => {
    mockClient.connect.mockRejectedValue(new Error('DB Error'));

    const event = {
      body: JSON.stringify({ username: 'miguel', password: 'miguel1' }),
    };
    const result = await lambda.handler(event);

    expect(result.statusCode).toBe(500);
    expect(result.body).toContain('Error interno del servidor');
  });
});