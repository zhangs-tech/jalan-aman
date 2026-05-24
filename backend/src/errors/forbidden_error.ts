import { AppError } from "./app_error";

export class ForbiddenError extends AppError {
  readonly statusCode = 403;

  constructor(message: string) {
    super(message);
  }
}
