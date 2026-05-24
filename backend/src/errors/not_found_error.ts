import { AppError } from "./app_error";

export class NotFoundError extends AppError {
  readonly statusCode = 404;
}
