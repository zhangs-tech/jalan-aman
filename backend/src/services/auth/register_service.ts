import bcrypt from "bcrypt";
import type PrismaUserRepository from "../../repositories/prisma_user_repository";

export interface RegisterRequest {
  email: string;
  password: string;
  name: string;
  phone: string;
}

export interface RegisterResponse {
  id: string;
  email: string;
  name: string;
  phone: string;
  role: string;
}

export class RegisterService {
  constructor(private readonly userRepository: PrismaUserRepository) { }

  async execute(data: RegisterRequest): Promise<RegisterResponse> {
    const { email, password, name, phone } = data;

    if (!email || !password || !name || !phone) {
      throw new Error(
        "Missing required fields: email, password, name, phone",
      );
    }

    const existingUser = await this.userRepository.findByEmail(email);

    if (existingUser) {
      throw new Error(
        "Email or username already exists",
      );
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const user = await this.userRepository.create({
      email,
      name,
      phone,
      hashedPassword: passwordHash,
      role: "user",
    });

    return {
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      role: user.role,
    };
  }
}