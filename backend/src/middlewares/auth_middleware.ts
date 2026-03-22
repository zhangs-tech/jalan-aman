import type { Request, Response, NextFunction } from "express";
import JwtService from "../services/auth/jwt_service";
import "../types/express";

const jwtService = new JwtService();

export const authMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    res.status(401).json({ message: "Unauthorized" });
    return;
  }

  const token = authHeader.split(" ")[1];

  if (!token) {
    res.status(401).json({ message: "Unauthorized" });
    return;
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
    res.status(401).json({ message: "Invalid token" });
    return;
  }
};