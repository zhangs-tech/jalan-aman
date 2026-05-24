import PrismaCommentRepository from "../../repositories/prisma_comment_repository";
import PrismaReportRepository from "../../repositories/prisma_report_repository";
import { NotFoundError } from "../../errors";
import { validateCommentSubmit } from "../../dtos/comment/comment-submit.dto";
import type { CommentSubmitResponse } from "../../dtos/comment/comment-submit.dto";
import type { CommentDTO } from "../../dtos/comment/comment.dto";
import type { ReportDTO } from "../../dtos/report-submit.dto";

export class CreateCommentService {
  constructor(
    private readonly commentRepository: PrismaCommentRepository,
    private readonly reportRepository: PrismaReportRepository
  ) {}

  async execute(
    input: unknown,
    reportId: string,
    userId: string
  ): Promise<CommentSubmitResponse> {
    const { details } = validateCommentSubmit(input);

    const report = await this.reportRepository.findById(reportId);
    if (!report) {
      throw new NotFoundError("Report not found");
    }

    const result = await this.commentRepository.create({
      details,
      reportId,
      userId,
    });

    const comment: CommentDTO = {
      id: result.id,
      reportId: result.reportId,
      userId: result.userId,
      userName: result.user.name,
      details: result.details,
      createdAt: result.createdAt,
      updatedAt: result.updatedAt,
    };

    const reportDto: ReportDTO = {
      id: report.id,
      reportType: report.reportType,
      description: report.description,
      createdAt: report.createdAt,
      updatedAt: report.updatedAt,
      expiresAt: report.expiresAt,
      reportedBy: report.reportedBy,
      latitude: report.latitude,
      longitude: report.longitude,
      address: report.address,
      zipCode: report.zipCode,
    };

    return { comment, report: reportDto };
  }
}
