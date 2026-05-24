import type { PrismaClient } from "../generated/prisma/client";

export default class PrismaAttachmentRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async findById(id: string) {
    return await this.prisma.attachment.findUnique({
      where: { id },
      include: {
        report: {
          select: { id: true },
        },
      },
    });
  }
}
