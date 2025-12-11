import app from "./app.js";
import { connectRabbitMQ } from "./utils/rabbitmq.js";

const PORT = process.env.PORT || 3002;

app.listen(PORT, "0.0.0.0", async () => {
  console.log(`Post Service running on port ${PORT}`);
  await connectRabbitMQ();
});
