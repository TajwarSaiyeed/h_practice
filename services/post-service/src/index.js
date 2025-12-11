import app from "./app.js";
import { connectRabbitMQ } from "./utils/rabbitmq.js";

const PORT = process.env.PORT || 3002;

app.listen(PORT, async () => {
  console.log(`Post Service running on port ${PORT}`);
  await connectRabbitMQ();
});
