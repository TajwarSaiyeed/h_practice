import express from "express";
import dotenv from "dotenv";
import { connectRabbitMQ, consumeEvent } from "./utils/rabbitmq.js";
import client from "prom-client";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3004;

// Prometheus Metrics
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({ register: client.register });

app.get("/metrics", async (req, res) => {
  res.setHeader("Content-Type", client.register.contentType);
  const metrics = await client.register.metrics();
  res.send(metrics);
});

app.get("/health", (req, res) => {
  res.status(200).json({ status: "UP" });
});

const startServer = async () => {
  await connectRabbitMQ();

  // Listen for Post Events
  consumeEvent("post_events", (msg) => {
    if (msg.event === "POST_CREATED") {
      console.log(
        `[NOTIFICATION] New Post Created by User ${msg.data.userId}: "${msg.data.title}"`
      );
      // Logic to send push notification to followers would go here
    }
  });

  // Listen for Interaction Events
  consumeEvent("interaction_events", (msg) => {
    if (msg.event === "INTERACTION_CREATED") {
      console.log(
        `[NOTIFICATION] User ${msg.data.userId} ${msg.data.type}D post ${msg.data.postId}`
      );
      // Logic to notify post owner would go here
    }
  });

  app.listen(PORT, () => {
    console.log(`Notification Service running on port ${PORT}`);
  });
};

startServer();
