import { AppError } from "./app_error";

export class BadRequestError extends AppError {
  readonly statusCode = 400;
}
