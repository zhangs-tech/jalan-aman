import { AppError } from "./app_error";

export class UnauthorizedError extends AppError {
  readonly statusCode = 401;
}
