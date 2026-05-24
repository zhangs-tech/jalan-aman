import PrismaReportRepository from "../../repositories/prisma_report_repository";
import PrismaVoteRepository from "../../repositories/prisma_vote_repository";
import { NotFoundError, ConflictError } from "../../errors";
import type { VoteResponse, ReportVoteDTO } from "../../dtos/vote.dto";
import type { ReportDTO } from "../../dtos/report-submit.dto";

const HOUR_MS = 60 * 60 * 1000;

export class VoteReportService {
  constructor(
    private readonly reportRepository: PrismaReportRepository,
    private readonly voteRepository: PrismaVoteRepository
  ) {}

  async execute(
    reportId: string,
    userId: string,
    type: "confirm" | "resolve"
  ): Promise<VoteResponse> {
    const report = await this.reportRepository.findById(reportId);
    if (!report) {
      throw new NotFoundError("Report not found");
    }

    const alreadyVoted = await this.voteRepository.hasRecentVote(reportId, userId, type);
    if (alreadyVoted) {
      throw new ConflictError(`Already voted ${type} within the last 24 hours`);
    }

    const capMs = report.createdAt.getTime() + 48 * HOUR_MS;
    const floorMs = report.createdAt.getTime() + 1 * HOUR_MS;

    const adjustment = type === "confirm" ? 1 * HOUR_MS : -1 * HOUR_MS;
    let newExpiresAt = new Date(report.expiresAt.getTime() + adjustment);

    if (newExpiresAt.getTime() > capMs) {
      newExpiresAt = new Date(capMs);
    }
    if (newExpiresAt.getTime() < floorMs) {
      newExpiresAt = new Date(floorMs);
    }

    const vote = await this.voteRepository.createVoteAndUpdateReport(
      reportId,
      userId,
      type,
      newExpiresAt
    );

    const voteDto: ReportVoteDTO = {
      reportId: vote.reportId,
      userId: vote.userId,
      type: vote.type,
      createdAt: vote.createdAt,
    };

    const updatedReport = await this.reportRepository.findById(reportId);

    const reportDto: ReportDTO = {
      id: updatedReport!.id,
      reportType: updatedReport!.reportType,
      description: updatedReport!.description,
      createdAt: updatedReport!.createdAt,
      updatedAt: updatedReport!.updatedAt,
      expiresAt: updatedReport!.expiresAt,
      reportedBy: updatedReport!.reportedBy,
      latitude: updatedReport!.latitude,
      longitude: updatedReport!.longitude,
      address: updatedReport!.address,
      zipCode: updatedReport!.zipCode,
    };

    return { vote: voteDto, report: reportDto };
  }
}
