import PrismaReportRepository from "../../repositories/prisma_report_repository";
import { z } from "zod";
import { BadRequestError } from "../../errors";
import { REPORT_TYPES } from "../../dtos/report-type.dto";
import type { ReportListResponse, ReportWithVotesDTO, VoteSummaryDTO } from "../../dtos/report-list.dto";
import type { ReportDTO } from "../../dtos/report-submit.dto";

const myReportsSchema = z.object({
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(50, "limit must be at most 50").default(20),
  reportType: z
    .string()
    .optional()
    .transform((val) => val?.split(",").filter(Boolean) ?? []),
});

export class GetReportsByUserService {
  constructor(private readonly reportRepository: PrismaReportRepository) {}

  async execute(query: unknown, userId: string): Promise<ReportListResponse> {
    const result = myReportsSchema.safeParse(query);
    if (!result.success) {
      const message = result.error.issues.map((i) => i.message).join("; ");
      throw new BadRequestError(message);
    }

    const params = result.data;

    if (params.reportType.length > 0) {
      for (const rt of params.reportType) {
        if (!(REPORT_TYPES as readonly string[]).includes(rt)) {
          throw new BadRequestError(`Unrecognized reportType filter: ${rt}`);
        }
      }
    }

    const { reports: rows, nextCursor } = await this.reportRepository.findByUserId({
      userId,
      limit: params.limit,
      ...(params.cursor !== undefined ? { cursor: params.cursor } : {}),
      ...(params.reportType.length > 0 ? { reportType: params.reportType } : {}),
    });

    const reports: ReportWithVotesDTO[] = rows.map((row) => {
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
      const userVote = row.votes.find((v) => v.userId === userId)?.type ?? null;

      const voteSummary: VoteSummaryDTO = { confirms, resolves, userVoted: userVote };

      return { ...reportDto, voteSummary };
    });

    return { reports, nextCursor };
  }
}
