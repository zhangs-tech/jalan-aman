// Shared user DTO used across auth, reports, and comments

export type UserDTO = {
  id: string;
  email: string;
  name: string;
  phone: string;
  role: string;
};
