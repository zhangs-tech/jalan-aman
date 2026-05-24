import { AppError } from "./AppError";

export class UnauthorizedError extends AppError {
  readonly statusCode = 401;
}
