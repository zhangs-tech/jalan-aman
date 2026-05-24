import bcrypt from "bcrypt";
import type PrismaUserRepository from "../../repositories/prisma_user_repository";
import JwtService from "./jwt_service";
import { UnauthorizedError } from "../../errors";
import { validateLogin } from "../../dtos/auth.dto";
import type { AuthLoginResponse, UserDTO } from "../../dtos/auth.dto";

export class LoginService {
  constructor(
    private readonly userRepository: PrismaUserRepository,
    private readonly jwtService: JwtService,
  ) {}

  async execute(input: unknown): Promise<AuthLoginResponse> {
    const { email, password } = validateLogin(input);

    const user = await this.userRepository.findByEmail(email);

    if (!user || !user.hashedPassword) {
      throw new UnauthorizedError("Invalid credentials");
    }

    const isPasswordValid = await bcrypt.compare(password, user.hashedPassword);

    if (!isPasswordValid) {
      throw new UnauthorizedError("Invalid credentials");
    }

    const accessToken = await this.jwtService.generate({
      id: user.id,
      email: user.email,
      role: user.role,
    });

    const userDto: UserDTO = {
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      role: user.role,
    };

    return {
      message: "Login successful",
      accessToken,
      user: userDto,
    };
  }
}
