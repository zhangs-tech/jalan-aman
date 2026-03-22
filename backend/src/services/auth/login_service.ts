import bcrypt from "bcrypt";
import type PrismaUserRepository from "../../repositories/prisma_user_repository";
import JwtService from "./jwt_service";

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  accessToken: string;
  user: {
    id: string;
    email: string;
    name: string;
    phone: string;
    role: string;
  };
}

export class LoginService {
  constructor(
    private readonly userRepository: PrismaUserRepository,
    private readonly jwtService: JwtService,
  ) { }

  async execute(data: LoginRequest): Promise<LoginResponse> {
    const { email, password } = data;

    if (!email || !password) {
      throw new Error("Missing required fields: email and password");
    }

    const user = await this.userRepository.findByEmail(email);

    if (!user || !user.hashedPassword) {
      throw new Error("Invalid credentials");
    }

    const isPasswordValid = await bcrypt.compare(password, user.hashedPassword);

    if (!isPasswordValid) {
      throw new Error("Invalid credentials");
    }

    const accessToken = await this.jwtService.generate({
      id: user.id,
      email: user.email,
      role: user.role,
    });

    return {
      accessToken,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        phone: user.phone,
        role: user.role,
      },
    };
  }
}