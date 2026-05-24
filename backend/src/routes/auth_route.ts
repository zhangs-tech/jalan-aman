import { Router } from "express";
import { AuthController } from "../controllers/auth_controller";
import prisma from "../prisma";
import PrismaUserRepository from "../repositories/prisma_user_repository";
import { RegisterService } from "../services/auth/register_service";
import { LoginService } from "../services/auth/login_service";
import JwtService from "../services/auth/jwt_service";
import { authMiddleware } from "../middlewares/auth_middleware";

const userRepository = new PrismaUserRepository(prisma);
const jwtService = new JwtService();
const registerService = new RegisterService(userRepository);
const loginService = new LoginService(userRepository, jwtService);
const authController = new AuthController(registerService, loginService);

export const authRouter = Router();

authRouter.post("/register", (req, res) =>
  authController.register(req, res),
);

authRouter.post("/login", (req, res) =>
  authController.login(req, res),
);

authRouter.get("/me", authMiddleware, (req, res) =>
  authController.getMe(req, res),
);

authRouter.post("/logout", authMiddleware, (req, res) =>
  authController.logout(req, res),
);