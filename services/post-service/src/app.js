import express from "express";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import postRoutes from "./routes/postRoutes.js";
import { metricsMiddleware } from "./utils/metrics.js";

dotenv.config();

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(cors());
app.use(helmet());
app.use(morgan("dev"));

app.get("/metrics", metricsMiddleware);
app.use("/api/posts", postRoutes);

app.get("/health", (req, res) => {
  res.status(200).json({ status: "UP" });
});

export default app;
