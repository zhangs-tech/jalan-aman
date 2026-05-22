import PrismaReportRepository from "../../repositories/prisma_report_repository";

export class GetReportsByUserService {
  constructor(private readonly reportRepository: PrismaReportRepository) {}

  async execute(userId: string) {
    if (!userId) {
      throw new Error("User ID is required to fetch reports");
    }

    return await this.reportRepository.findByUserId(userId);
  }
}
