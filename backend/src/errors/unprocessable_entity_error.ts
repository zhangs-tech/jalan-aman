import { AppError } from "./app_error";

export class UnprocessableEntityError extends AppError {
  readonly statusCode = 422;

  constructor(message: string) {
    super(message);
  }
}
