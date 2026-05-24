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
    let cursorClause: { cursor: { createdAt: Date; id: string }; skip: number } | Record<string, never> = {};
    if (cursor) {
      const parsed: { createdAt: string; id: string } = JSON.parse(
        Buffer.from(cursor, "base64").toString("utf-8")
      );
      cursorClause = {
        cursor: { createdAt: new Date(parsed.createdAt), id: parsed.id },
        skip: 1,
      };
    }

    const rows = (await this.prisma.comment.findMany({
      where: { reportId },
      orderBy: [{ createdAt: "asc" }, { id: "asc" }],
      take: limit + 1,
      ...cursorClause,
      include: {
        user: { select: { id: true, name: true } },
      },
    })) as CommentRow[];

    const hasMore = rows.length > limit;
    const comments = hasMore ? rows.slice(0, limit) : rows;
    const nextCursor = hasMore
      ? Buffer.from(
          JSON.stringify({
            createdAt: comments[comments.length - 1]!.createdAt.toISOString(),
            id: comments[comments.length - 1]!.id,
          })
        ).toString("base64")
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
