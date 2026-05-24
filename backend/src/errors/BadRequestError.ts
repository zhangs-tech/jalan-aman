import { AppError } from "./AppError";

export class BadRequestError extends AppError {
  readonly statusCode = 400;
}
