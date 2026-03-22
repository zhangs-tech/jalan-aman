import PrismaReportRepository from "../../repositories/prisma_report_repository";

export class GetReportByIdService {
  constructor(private readonly reportRepository: PrismaReportRepository) { }

  async execute(id: string) {
    const report = await this.reportRepository.findById(id);
    if (!report) {
      throw new Error("Report not found");
    }
    return report;
  }
}
