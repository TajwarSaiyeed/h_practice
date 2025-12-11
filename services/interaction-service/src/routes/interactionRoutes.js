import express from "express";
import {
  toggleInteraction,
  getInteractions,
} from "../controllers/interactionController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

router.get("/health", (req, res) => {
  res.status(200).json({ status: "UP" });
});

router.route("/:postId").post(protect, toggleInteraction).get(getInteractions);

export default router;
