const lambda = require('./index');
const { Pool } = require('pg');

// Mock de pg y aws-sdk
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

jest.mock('aws-sdk', () => {
  const putRecordMock = jest.fn().mockReturnValue({ promise: jest.fn().mockResolvedValue({}) });
  return {
    config: { update: jest.fn() },
    Kinesis: jest.fn(() => ({
      putRecord: putRecordMock,
    })),
  };
});

describe('Lambda Function - createEvent', () => {
  let mockClient;

  beforeEach(() => {
    mockClient = new Pool();
    jest.clearAllMocks();
  });

  test('should return 201 and event data if insert and Kinesis succeed', async () => {
    const fakeEvent = {
      body: JSON.stringify({
        title: 'Test Event',
        description: 'Test Desc',
        date: '2025-06-29',
        location: 'Online'
      })
    };
    const fakeRow = { id: 1, title: 'Test Event', description: 'Test Desc', event_date: '2025-06-29', location: 'Online' };
    mockClient.connect.mockResolvedValue(mockClient);
    mockClient.query.mockResolvedValue({ rows: [fakeRow] });

    const result = await lambda.handler(fakeEvent);

    expect(result.statusCode).toBe(201);
    expect(result.body).toContain('Evento creado exitosamente');
    expect(JSON.parse(result.body).event).toEqual(fakeRow);
  });

  test('should return 500 if DB insert fails', async () => {
    const fakeEvent = {
      body: JSON.stringify({
        title: 'Test Event',
        description: 'Test Desc',
        date: '2025-06-29',
        location: 'Online'
      })
    };
    mockClient.connect.mockResolvedValue(mockClient);
    mockClient.query.mockRejectedValue(new Error('DB Error'));

    const result = await lambda.handler(fakeEvent);

    expect(result.statusCode).toBe(500);
    expect(result.body).toContain('Error al crear el evento');
  });

  test('should return 500 if body is missing', async () => {
    const result = await lambda.handler({});
    expect(result.statusCode).toBe(500);
    expect(result.body).toContain('Error al crear el evento');
  });
});