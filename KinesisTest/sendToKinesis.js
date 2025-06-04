// sendToKinesis.js
const AWS = require("aws-sdk");

// Configurar la región (debes usar la misma que usaste en Terraform, por ejemplo "us-east-2")
AWS.config.update({ region: "us-east-2" });

// Instanciar Kinesis
const kinesis = new AWS.Kinesis();

// Definir el mensaje a enviar
const data = {
  id: Date.now(),
  message: "Hola desde Node.js, probando Kinesis con amor ❤️"
};

// Configurar los parámetros del envío
const params = {
  Data: JSON.stringify(data),
  PartitionKey: "partitionKey-1", // Puede ser cualquier string
  StreamName: "event-stream"
};

// Enviar el mensaje
kinesis.putRecord(params, function (err, data) {
  if (err) {
    console.error("❌ Error al enviar el mensaje:", err);
  } else {
    console.log("✅ Mensaje enviado correctamente a Kinesis:", data);
  }
});