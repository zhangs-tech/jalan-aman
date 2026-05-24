import PrismaCommentRepository from "../../repositories/prisma_comment_repository";
import PrismaReportRepository from "../../repositories/prisma_report_repository";
import { NotFoundError } from "../../errors";
import { validateCommentListParams } from "../../dtos/comment/comment-list.dto";
import type { CommentListResponse } from "../../dtos/comment/comment-list.dto";
import type { CommentDTO } from "../../dtos/comment/comment.dto";

export class GetCommentsByReportIdService {
  constructor(
    private readonly commentRepository: PrismaCommentRepository,
    private readonly reportRepository: PrismaReportRepository
  ) {}

  async execute(reportId: string, query: unknown): Promise<CommentListResponse> {
    const report = await this.reportRepository.findById(reportId);
    if (!report) {
      throw new NotFoundError("Report not found");
    }

    const { cursor, limit } = validateCommentListParams(query);

    const result = await this.commentRepository.findByReportId(reportId, cursor, limit);

    const comments: CommentDTO[] = result.comments.map((row) => ({
      id: row.id,
      reportId: row.reportId,
      userId: row.userId,
      userName: row.user.name,
      details: row.details,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    }));

    return { comments, nextCursor: result.nextCursor };
  }
}
