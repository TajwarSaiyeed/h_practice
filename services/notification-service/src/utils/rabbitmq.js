import amqp from "amqplib";

let channel = null;

export const connectRabbitMQ = async () => {
  try {
    const connection = await amqp.connect("amqp://guest:guest@rabbitmq:5672");
    channel = await connection.createChannel();
    console.log("Connected to RabbitMQ");
    return channel;
  } catch (error) {
    console.error("RabbitMQ Connection Error:", error);
    setTimeout(connectRabbitMQ, 5000);
  }
};

export const getChannel = () => channel;

export const publishEvent = async (queue, message) => {
  if (!channel) {
    console.error("RabbitMQ channel not available");
    return;
  }
  await channel.assertQueue(queue, { durable: true });
  channel.sendToQueue(queue, Buffer.from(JSON.stringify(message)));
  console.log(`Event published to ${queue}`);
};

export const consumeEvent = async (queue, callback) => {
  if (!channel) {
    const interval = setInterval(async () => {
      if (channel) {
        clearInterval(interval);
        await channel.assertQueue(queue, { durable: true });
        channel.consume(queue, (msg) => {
          if (msg !== null) {
            const content = JSON.parse(msg.content.toString());
            callback(content);
            channel.ack(msg);
          }
        });
      }
    }, 1000);
    return;
  }
  await channel.assertQueue(queue, { durable: true });
  channel.consume(queue, (msg) => {
    if (msg !== null) {
      const content = JSON.parse(msg.content.toString());
      callback(content);
      channel.ack(msg);
    }
  });
};
