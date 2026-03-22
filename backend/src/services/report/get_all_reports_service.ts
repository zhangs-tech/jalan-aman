import PrismaReportRepository from "../../repositories/prisma_report_repository";

export class GetAllReportsService {
  constructor(private readonly reportRepository: PrismaReportRepository) {}

  async execute() {
    return await this.reportRepository.findAll();
  }
}
