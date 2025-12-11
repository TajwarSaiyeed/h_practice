import express from "express";
import {
  authUser,
  registerUser,
  logoutUser,
  getUserProfile,
} from "../controllers/authController.js";
import { protect } from "../middleware/authMiddleware.js";
import {
  validateRegister,
  validateLogin,
} from "../middleware/validationMiddleware.js";

const router = express.Router();

router.post("/register", validateRegister, registerUser);
router.post("/auth", validateLogin, authUser);
router.post("/logout", logoutUser);
router.get("/profile", protect, getUserProfile);

export default router;
