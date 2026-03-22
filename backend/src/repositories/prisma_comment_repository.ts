import type { PrismaClient, Prisma } from "../generated/prisma/client";

export default class PrismaCommentRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async create(data: Prisma.CommentCreateInput) {
    return await this.prisma.comment.create({ data });
  }

  async findByReportId(reportID: string) {
    return await this.prisma.comment.findMany({
      where: { reportID },
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: { id: true, name: true }
        }
      }
    });
  }

  async findById(commentID: string) {
    return await this.prisma.comment.findUnique({
      where: { commentID }
    });
  }

  async update(commentID: string, details: string) {
    return await this.prisma.comment.update({
      where: { commentID },
      data: { details }
    });
  }
}
