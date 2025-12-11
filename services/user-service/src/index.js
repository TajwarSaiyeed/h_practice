import app from "./app.js";
import startGrpcServer from "./grpcServer.js";
import { connectRabbitMQ } from "./utils/rabbitmq.js";

const port = process.env.PORT || 3001;

app.listen(port, "0.0.0.0", async () => {
  console.log(`Server running on port ${port}`);
  startGrpcServer();
  await connectRabbitMQ();
});
