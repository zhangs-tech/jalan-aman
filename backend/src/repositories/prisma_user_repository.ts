import type { PrismaClient, Prisma } from "../generated/prisma/client";

export default class PrismaUserRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async create(data: Prisma.UserCreateInput) {
    return await this.prisma.user.create({ data });
  }

  async findByEmail(email: string) {
    return await this.prisma.user.findUnique({ where: { email } });
  }
}