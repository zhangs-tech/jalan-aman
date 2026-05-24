import PrismaReportRepository from "../../repositories/prisma_report_repository";
import { NotFoundError } from "../../errors";

export class GetReportByIdService {
  constructor(private readonly reportRepository: PrismaReportRepository) { }

  async execute(id: string) {
    const report = await this.reportRepository.findById(id);
    if (!report) {
      throw new NotFoundError("Report not found");
    }
    return report;
  }
}
