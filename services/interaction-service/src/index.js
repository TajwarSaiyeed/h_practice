import app from "./app.js";
import { connectRabbitMQ, consumeEvent } from "./utils/rabbitmq.js";

const PORT = process.env.PORT || 3003;

app.listen(PORT, "0.0.0.0", async () => {
  console.log(`Interaction Service running on port ${PORT}`);
  await connectRabbitMQ();

  // Consume events from Post Service
  consumeEvent("post_events", (msg) => {
    console.log("Received Event in Interaction Service:", msg);
    if (msg.event === "POST_CREATED") {
      console.log(
        `Processing new post: ${msg.data.title} (ID: ${msg.data.postId})`
      );
      // Here we could initialize interaction stats for the new post
    }
  });
});
