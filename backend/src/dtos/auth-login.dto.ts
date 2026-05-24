// DTOs for "Login" use case
// See: docs/use_cases/login_use_case.md

import { z } from "zod";
import { BadRequestError } from "../errors";
import type { UserDTO } from "./user.dto";

// ---------------------------------------------------------------------------
// Schema
// ---------------------------------------------------------------------------

export const loginSchema = z.object({
  email: z.string().min(1, "email must be a non-empty string"),
  password: z.string().min(1, "password must be a non-empty string"),
});

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type AuthLoginDTO = z.infer<typeof loginSchema>;

export type AuthLoginResponse = {
  message: string;
  accessToken: string;
  user: UserDTO;
};

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------

export function validateLogin(input: unknown): AuthLoginDTO {
  const result = loginSchema.safeParse(input);
  if (!result.success) {
    const message = result.error.issues.map((i) => i.message).join("; ");
    throw new BadRequestError(message);
  }
  return result.data;
}
