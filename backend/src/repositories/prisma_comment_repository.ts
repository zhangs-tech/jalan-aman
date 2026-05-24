import type { PrismaClient } from "../generated/prisma/client";

export type CreateCommentData = {
  details: string;
  reportId: string;
  userId: string;
};

export default class PrismaCommentRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async create(data: CreateCommentData) {
    return await this.prisma.comment.create({
      data: {
        details: data.details,
        report: { connect: { id: data.reportId } },
        user: { connect: { id: data.userId } },
      },
    });
  }

  async findByReportId(reportId: string) {
    return await this.prisma.comment.findMany({
      where: { reportId },
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: { id: true, name: true }
        }
      }
    });
  }

  async findById(id: string) {
    return await this.prisma.comment.findUnique({
      where: { id }
    });
  }

  async update(id: string, details: string) {
    return await this.prisma.comment.update({
      where: { id },
      data: { details }
    });
  }

  async delete(id: string) {
    return await this.prisma.comment.delete({
      where: { id }
    });
  }
}
