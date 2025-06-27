const handler = require("./index").handler;

describe("Lambda sqsSesConsumer", () => {
  it("should send email for each record and return status 200", async () => {
    process.env.EMAIL_TO = "govench6@gmail.com";
    process.env.EMAIL_FROM = "govench6@gmail.com";

    const sendEmailMock = jest.fn(() => ({
      promise: () => Promise.resolve(),
    }));

    const sesMock = {
      sendEmail: sendEmailMock,
    };

    const event = {
      Records: [
        { body: "Mensaje de prueba 1" },
        { body: "Mensaje de prueba 2" },
      ],
    };

    const response = await handler(event, sesMock); // inyectamos el mock directamente

    expect(response.statusCode).toBe(200);
    expect(response.body).toBe("Proceso completado.");

    expect(sendEmailMock).toHaveBeenCalledTimes(2);

    expect(sendEmailMock).toHaveBeenCalledWith(
      expect.objectContaining({
        Destination: expect.objectContaining({
          ToAddresses: expect.any(Array),
        }),
        Message: expect.any(Object),
        Source: expect.any(String),
      })
    );
  });
});