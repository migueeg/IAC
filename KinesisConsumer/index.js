const AWS = require('aws-sdk');

exports.handler = async (event) => {
  for (const record of event.Records) {
    const payload = Buffer.from(record.kinesis.data, 'base64').toString('utf-8');
    console.log("Mensaje recibido desde Kinesis:", payload);
  }

  return { statusCode: 200 };
};