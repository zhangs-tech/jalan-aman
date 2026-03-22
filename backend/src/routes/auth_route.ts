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

authRouter.post("/register", (req, res, next) =>
  authController.register(req, res, next),
);

authRouter.post("/login", (req, res, next) =>
  authController.login(req, res, next),
);

authRouter.get("/me", authMiddleware, (req, res, next) =>
  authController.getMe(req, res, next),
);

authRouter.post("/logout", authMiddleware, (req, res, next) =>
  authController.logout(req, res, next),
);