const AWS = require("aws-sdk");

exports.handler = async (event, context, callback, injectedSes) => {
  const sesInstance = injectedSes || new AWS.SES();

  for (const record of event.Records) {
    const messageBody = record.body;

    const params = {
      Destination: {
        ToAddresses: [process.env.EMAIL_TO],
      },
      Message: {
        Body: {
          Text: {
            Data: `Nuevo mensaje recibido desde SQS:\n\n${messageBody}`,
          },
        },
        Subject: {
          Data: "Notificación desde Lambda + SQS + SES",
        },
      },
      Source: process.env.EMAIL_FROM,
    };

    try {
      await sesInstance.sendEmail(params).promise();
      console.log("Correo enviado con éxito.");
    } catch (error) {
      console.error("Error al enviar correo:", error);
    }
  }

  return {
    statusCode: 200,
    body: "Proceso completado.",
  };
};