import client from "prom-client";

// Create a Registry which registers the metrics
const register = new client.Registry();

// Add a default label which is added to all metrics
client.collectDefaultMetrics({
  app: "user-service",
  prefix: "node_",
  timeout: 10000,
  gcDurationBuckets: [0.001, 0.01, 0.1, 1, 2, 5],
  register,
});

export const metricsMiddleware = async (req, res) => {
  res.setHeader("Content-Type", register.contentType);
  res.send(await register.metrics());
};
