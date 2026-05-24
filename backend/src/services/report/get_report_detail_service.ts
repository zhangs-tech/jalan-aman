import PrismaReportRepository from "../../repositories/prisma_report_repository";
import { NotFoundError } from "../../errors";
import type { ReportDetailResponse, ReportDetailDTO, VoteSummaryDTO, AttachmentDetailDTO } from "../../dtos/report-detail.dto";
import type { ReportDTO } from "../../dtos/report-submit.dto";

export class GetReportDetailService {
  constructor(private readonly reportRepository: PrismaReportRepository) {}

  async execute(reportId: string, userId?: string): Promise<ReportDetailResponse> {
    const row = await this.reportRepository.findDetailById(reportId);

    if (!row || row.deletedAt !== null) {
      throw new NotFoundError("Report not found");
    }

    const reportDto: ReportDTO = {
      id: row.id,
      reportType: row.reportType,
      description: row.description,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      expiresAt: row.expiresAt,
      reportedBy: row.reportedBy,
      latitude: row.latitude,
      longitude: row.longitude,
      address: row.address,
      zipCode: row.zipCode,
    };

    const confirms = row.votes.filter((v) => v.type === "confirm").length;
    const resolves = row.votes.filter((v) => v.type === "resolve").length;
    const userVoted = userId
      ? row.votes.find((v) => v.userId === userId)?.type ?? null
      : null;

    const voteSummary: VoteSummaryDTO = { confirms, resolves, userVoted };

    const attachments: AttachmentDetailDTO[] = row.attachments.map((att) => ({
      id: att.id,
      s3Key: att.s3Key,
      mimeType: att.mimeType,
      fileSize: att.fileSize,
      createdAt: att.createdAt,
    }));

    const report: ReportDetailDTO = {
      ...reportDto,
      commentCount: row._count.comments,
      voteSummary,
      attachments,
    };

    return { report };
  }
}
