const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");

exports.handler = async (event, context, callback, injectedSes) => {
  const sesClient = injectedSes || new SESClient({});

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
      const command = new SendEmailCommand(params);
      await sesClient.send(command);
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