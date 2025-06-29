const { Pool } = require('pg');
const AWS = require('aws-sdk');

AWS.config.update({ region: 'us-east-2' });
const kinesis = new AWS.Kinesis();

const pool = new Pool({
  host: process.env.DB_HOST.split(':')[0],
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  port: 5432,
  ssl: {
    rejectUnauthorized: false
  }
});

exports.handler = async (event) => {
  try {
    const { title, description, date, location } = JSON.parse(event.body);
    
    const client = await pool.connect();
    
    const query = 'INSERT INTO events (title, description, event_date, location) VALUES ($1, $2, $3, $4) RETURNING *';
    const values = [title, description, date, location];
    
    const result = await client.query(query, values);
    client.release();

    // Enviar a Kinesis
    const payload = {
      id: Date.now(),
      title,
      description,
      date,
      location
    };

    const kinesisParams = {
      Data: JSON.stringify(payload),
      PartitionKey: String(Date.now()),
      StreamName: 'event-stream'
    };

    console.log("Enviando a Kinesis...");
    try {
      await kinesis.putRecord(kinesisParams).promise();
      console.log("Evento enviado a Kinesis:", payload);
    } catch (kinesisError) {
      console.error("Error enviando a Kinesis:", kinesisError);
    }

    return {
      statusCode: 201,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        message: 'Evento creado exitosamente',
        event: result.rows[0]
      })
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        message: 'Error al crear el evento',
        error: error.message
      })
    };
  }
};