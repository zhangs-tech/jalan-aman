import PrismaReportRepository from "../../repositories/prisma_report_repository";
import { validateReportListParams } from "../../dtos/report-list.dto";
import type { ReportListResponse, ReportWithVotesDTO, VoteSummaryDTO } from "../../dtos/report-list.dto";
import type { ReportDTO } from "../../dtos/report-submit.dto";

export class ListReportsService {
  constructor(private readonly reportRepository: PrismaReportRepository) {}

  async execute(query: unknown, userId?: string): Promise<ReportListResponse> {
    const params = validateReportListParams(query);

    const result = await this.reportRepository.findMany({
      limit: params.limit,
      sort: params.sort,
      order: params.order,
      ...(params.cursor !== undefined ? { cursor: params.cursor } : {}),
      ...(params.reportType.length > 0 ? { reportType: params.reportType } : {}),
    });

    const reports: ReportWithVotesDTO[] = result.reports.map((row) => {
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
      const userVote = userId
        ? row.votes.find((v) => v.userId === userId)?.type ?? null
        : null;

      const voteSummary: VoteSummaryDTO = { confirms, resolves, userVoted: userVote };

      return { ...reportDto, voteSummary };
    });

    return { reports, nextCursor: result.nextCursor };
  }
}
