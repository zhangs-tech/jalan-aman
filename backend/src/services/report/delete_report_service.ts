import PrismaReportRepository from "../../repositories/prisma_report_repository";
import { ForbiddenError, NotFoundError } from "../../errors";

export class DeleteReportService {
  constructor(private readonly reportRepository: PrismaReportRepository) {}

  async execute(reportId: string, userId: string): Promise<void> {
    const report = await this.reportRepository.findById(reportId);
    if (!report) {
      throw new NotFoundError("Report not found");
    }

    if (report.reportedBy !== userId) {
      throw new ForbiddenError("You can only delete your own reports");
    }

    await this.reportRepository.softDelete(reportId);
  }
}
