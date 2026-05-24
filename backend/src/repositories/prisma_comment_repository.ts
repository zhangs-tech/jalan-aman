import type { PrismaClient } from "../generated/prisma/client";

export type CreateCommentData = {
  details: string;
  reportId: string;
  userId: string;
};

export type CreateCommentResult = {
  id: string;
  reportId: string;
  userId: string;
  details: string;
  createdAt: Date;
  updatedAt: Date;
  user: { id: string; name: string };
};

export type CommentRow = {
  id: string;
  reportId: string;
  userId: string;
  details: string;
  createdAt: Date;
  updatedAt: Date;
  user: { id: string; name: string };
};

export type PaginatedCommentsResult = {
  comments: CommentRow[];
  nextCursor: string | null;
};

export default class PrismaCommentRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async create(data: CreateCommentData): Promise<CreateCommentResult> {
    return (await this.prisma.comment.create({
      data: {
        details: data.details,
        report: { connect: { id: data.reportId } },
        user: { connect: { id: data.userId } },
      },
      include: {
        user: { select: { id: true, name: true } },
      },
    })) as CreateCommentResult;
  }

  async findByReportId(
    reportId: string,
    cursor?: string,
    limit: number = 20
  ): Promise<PaginatedCommentsResult> {
    const take = limit + 1;

    const where: Record<string, unknown> = { reportId };

    if (cursor) {
      const cursorDate = new Date(Buffer.from(cursor, "base64").toString("utf-8"));
      where.createdAt = { gt: cursorDate };
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const rows = (await this.prisma.comment.findMany({
      where: where as any,
      orderBy: { createdAt: "asc" },
      take,
      include: {
        user: { select: { id: true, name: true } },
      },
    })) as CommentRow[];

    const hasMore = rows.length > limit;
    const comments = hasMore ? rows.slice(0, limit) : rows;
    const nextCursor = hasMore
      ? Buffer.from(comments[comments.length - 1]!.createdAt.toISOString()).toString("base64")
      : null;

    return { comments, nextCursor };
  }

  async findById(id: string) {
    return await this.prisma.comment.findUnique({
      where: { id },
    });
  }

  async update(id: string, details: string) {
    return await this.prisma.comment.update({
      where: { id },
      data: { details },
    });
  }

  async delete(id: string) {
    return await this.prisma.comment.delete({
      where: { id },
    });
  }
}
