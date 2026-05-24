import { AppError } from "./app_error";

export class ConflictError extends AppError {
  readonly statusCode = 409;
}
