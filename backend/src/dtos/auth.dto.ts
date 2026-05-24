// DTOs for auth use cases
// See: docs/use_cases/login_use_case.md, register_use_case.md, logout_use_case.md

import { BadRequestError } from "../errors";

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

export type UserDTO = {
  id: string;
  email: string;
  name: string;
  phone: string;
  role: string;
};

// ---------------------------------------------------------------------------
// Login
// ---------------------------------------------------------------------------

export type AuthLoginDTO = {
  email: string;
  password: string;
};

export type AuthLoginResponse = {
  message: string;
  accessToken: string;
  user: UserDTO;
};

export function validateLogin(input: unknown): AuthLoginDTO {
  if (typeof input !== "object" || input === null) {
    throw new BadRequestError("Request body must be a JSON object");
  }

  const body = input as Record<string, unknown>;
  const { email, password } = body;

  if (email == null || password == null) {
    throw new BadRequestError("Missing required fields: email, password");
  }

  if (typeof email !== "string" || email.length === 0) {
    throw new BadRequestError("email must be a non-empty string");
  }

  if (typeof password !== "string" || password.length === 0) {
    throw new BadRequestError("password must be a non-empty string");
  }

  return { email, password };
}

// ---------------------------------------------------------------------------
// Register
// ---------------------------------------------------------------------------

export type AuthRegisterDTO = {
  email: string;
  password: string;
  name: string;
  phone: string;
};

export type AuthRegisterResponse = {
  message: string;
  user: UserDTO;
};

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function validateRegister(input: unknown): AuthRegisterDTO {
  if (typeof input !== "object" || input === null) {
    throw new BadRequestError("Request body must be a JSON object");
  }

  const body = input as Record<string, unknown>;
  const { email, password, name, phone } = body;

  if (email == null || password == null || name == null || phone == null) {
    throw new BadRequestError("Missing required fields: email, password, name, phone");
  }

  if (typeof email !== "string" || !EMAIL_RE.test(email)) {
    throw new BadRequestError("email must be a valid email address");
  }

  if (typeof password !== "string") {
    throw new BadRequestError("password must be a string");
  }

  if (password.length < 8) {
    throw new BadRequestError("password must be at least 8 characters");
  }

  if (!/[A-Z]/.test(password)) {
    throw new BadRequestError("password must contain at least one uppercase letter");
  }

  if (!/[a-z]/.test(password)) {
    throw new BadRequestError("password must contain at least one lowercase letter");
  }

  if (!/[0-9]/.test(password)) {
    throw new BadRequestError("password must contain at least one digit");
  }

  if (typeof name !== "string" || name.trim().length === 0) {
    throw new BadRequestError("name must be a non-empty string");
  }

  if (typeof phone !== "string" || phone.trim().length === 0) {
    throw new BadRequestError("phone must be a non-empty string");
  }

  return { email, password, name: name.trim(), phone: phone.trim() };
}
