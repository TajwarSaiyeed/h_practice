import express from "express";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import interactionRoutes from "./routes/interactionRoutes.js";
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
app.use("/api/interactions", interactionRoutes);

export default app;
