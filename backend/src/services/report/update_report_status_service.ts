import { ReportStatus } from "../../generated/prisma/client";
import PrismaReportRepository from "../../repositories/prisma_report_repository";

export class UpdateReportStatusService {
  constructor(private readonly reportRepository: PrismaReportRepository) {}

  async execute(reportId: string, newStatus: ReportStatus, changedBy: string, details: string, imgB64?: string) {
    if (!newStatus || !details) {
      throw new Error("New status and details must be provided");
    }

    return await this.reportRepository.updateStatus(reportId, newStatus, changedBy, details, imgB64);
  }
}
