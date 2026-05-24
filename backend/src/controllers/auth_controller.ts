import type { NextFunction, Request, Response } from "express";
import type { RegisterService } from "../services/auth/register_service";
import type { LoginService } from "../services/auth/login_service";
import { ValidationError } from "../services/auth/validation_error";

export class AuthController {
  constructor(
    private readonly registerService: RegisterService,
    private readonly loginService: LoginService,
  ) {}

  async register(
    req: Request,
    res: Response,
    next: NextFunction,
  ): Promise<void> {
    try {
      const result = await this.registerService.execute(req.body);
      res
        .status(201)
        .json({ message: "Registration successful", user: result });
    } catch (error) {
      res.status(409).json({ message: "Email already registered" });
      next(error as Error);
    }
  }

  async login(req: Request, res: Response, _next: NextFunction): Promise<void> {
    try {
      const result = await this.loginService.execute(req.body);
      res.status(200).json({ message: "Login successful", ...result });
    } catch (error) {
      const err = error as Error;
      if (error instanceof ValidationError) {
        res.status(400).json({ message: err.message });
      } else {
        res.status(401).json({ message: err.message || "Login failed" });
      }
    }
  }

  async getMe(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ message: "Unauthorized" });
        return;
      }
      res.status(200).json({ user: req.user });
    } catch (error) {
      next(error as Error);
    }
  }

  async logout(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      res.status(200).json({ message: "Logout successful" });
    } catch (error) {
      next(error as Error);
    }
  }
}
