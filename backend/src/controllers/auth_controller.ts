import type { Request, Response } from "express";
import type { RegisterService } from "../services/auth/register_service";
import type { LoginService } from "../services/auth/login_service";
import { UnauthorizedError } from "../errors";

export class AuthController {
  constructor(
    private readonly registerService: RegisterService,
    private readonly loginService: LoginService,
  ) {}

  async register(req: Request, res: Response): Promise<void> {
    const result = await this.registerService.execute(req.body);
    res.status(201).json(result);
  }

  async login(req: Request, res: Response): Promise<void> {
    const result = await this.loginService.execute(req.body);
    res.status(200).json(result);
  }

  async getMe(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new UnauthorizedError("Unauthorized");
    }
    res.status(200).json({ user: req.user });
  }

  async logout(_req: Request, res: Response): Promise<void> {
    res.status(200).json({ message: "Logout successful" });
  }
}
