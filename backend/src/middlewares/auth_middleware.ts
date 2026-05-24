import type { Request, Response, NextFunction } from "express";
import JwtService from "../services/auth/jwt_service";
import { UnauthorizedError } from "../errors";
import "../types/express";

const jwtService = new JwtService();

export const authMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return next(new UnauthorizedError("Unauthorized"));
  }

  const token = authHeader.split(" ")[1];

  if (!token) {
    return next(new UnauthorizedError("Unauthorized"));
  }

  try {
    const decoded = await jwtService.verify(token);
    req.user = {
      id: decoded.id,
      email: decoded.email,
      role: decoded.role,
    };
    next();
  } catch (_error) {
    return next(new UnauthorizedError("Invalid token"));
  }
};