// DTOs for "Register" use case
// See: docs/use_cases/register_use_case.md

import { z } from "zod";
import { BadRequestError } from "../errors";
import type { UserDTO } from "./user.dto";

// ---------------------------------------------------------------------------
// Schema
// ---------------------------------------------------------------------------

export const registerSchema = z.object({
  email: z.string().email("email must be a valid email address"),
  password: z
    .string()
    .min(8, "password must be at least 8 characters")
    .regex(/[A-Z]/, "password must contain at least one uppercase letter")
    .regex(/[a-z]/, "password must contain at least one lowercase letter")
    .regex(/[0-9]/, "password must contain at least one digit"),
  name: z.string().min(1, "name must be a non-empty string"),
  phone: z.string().min(1, "phone must be a non-empty string"),
});

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type AuthRegisterDTO = z.infer<typeof registerSchema>;

export type AuthRegisterResponse = {
  message: string;
  user: UserDTO;
};

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------

export function validateRegister(input: unknown): AuthRegisterDTO {
  const result = registerSchema.safeParse(input);
  if (!result.success) {
    const message = result.error.issues.map((i) => i.message).join("; ");
    throw new BadRequestError(message);
  }
  return result.data;
}
