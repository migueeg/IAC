// Importamos el módulo pg para conectarnos a PostgreSQL
const { Pool } = require('pg');

// Log inicial para verificar que la Lambda se está ejecutando
console.log('Lambda iniciando...');

// Log de variables de entorno (sin mostrar passwords)
console.log('Variables de entorno:', {
  DB_HOST: process.env.DB_HOST,
  DB_NAME: process.env.DB_NAME,
  DB_USER: process.env.DB_USER
});

const pool = new Pool({
  host: process.env.DB_HOST ? process.env.DB_HOST.split(':')[0] : null,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  port: 5432,
  ssl: {
    rejectUnauthorized: false
  }
});

exports.handler = async (event) => {
  let client;
  
  try {
    // Log del evento recibido
    console.log('Evento recibido:', JSON.stringify(event));

    // Validación del body
    if (!event.body) {
      throw new Error('No se recibió body en la petición');
    }

    // Establecemos conexión con la base de datos
    console.log('Intentando conectar a la base de datos...');
    client = await pool.connect();
    console.log('Conexión exitosa a la base de datos');

    const { username, password } = JSON.parse(event.body);
    console.log('Datos de login recibidos para usuario:', username);

    const query = 'SELECT id, username FROM users WHERE username = $1 AND password = $2';
    console.log('Ejecutando query...');
    const result = await client.query(query, [username, password]);
    console.log('Query ejecutado. Filas encontradas:', result.rows.length);

    return {
      statusCode: result.rows.length > 0 ? 200 : 401,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': true,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        message: result.rows.length > 0 ? 'Login exitoso' : 'Credenciales inválidas',
        user: result.rows[0]
      })
    };
  } catch (error) {
    console.error('Error detallado:', {
      name: error.name,
      message: error.message,
      stack: error.stack,
      code: error.code,
      event: event
    });

    return {
      statusCode: 500,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ 
        message: 'Error interno del servidor',
        error: error.message,
        type: error.name
      })
    };
  } finally {
    if (client) {
      try {
        await client.release();
        console.log('Conexión liberada');
      } catch (releaseError) {
        console.error('Error al liberar conexión:', releaseError);
      }
    }
  }
};