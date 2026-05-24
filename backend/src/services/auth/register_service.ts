import bcrypt from "bcrypt";
import type PrismaUserRepository from "../../repositories/prisma_user_repository";
import { ConflictError } from "../../errors";
import { validateRegister } from "../../dtos/auth-register.dto";
import type { AuthRegisterResponse } from "../../dtos/auth-register.dto";
import type { UserDTO } from "../../dtos/user.dto";

export class RegisterService {
  constructor(private readonly userRepository: PrismaUserRepository) {}

  async execute(input: unknown): Promise<AuthRegisterResponse> {
    const { email, password, name, phone } = validateRegister(input);

    const existingUser = await this.userRepository.findByEmail(email);

    if (existingUser) {
      throw new ConflictError("Email already registered");
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

    const userDto: UserDTO = {
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      role: user.role,
    };

    return {
      message: "Registration successful",
      user: userDto,
    };
  }
}
