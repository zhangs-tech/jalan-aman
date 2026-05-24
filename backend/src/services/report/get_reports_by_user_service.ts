import PrismaReportRepository from "../../repositories/prisma_report_repository";
import { BadRequestError } from "../../errors";

export class GetReportsByUserService {
  constructor(private readonly reportRepository: PrismaReportRepository) {}

  async execute(userId: string) {
    if (!userId) {
      throw new BadRequestError("User ID is required to fetch reports");
    }

    return await this.reportRepository.findByUserId(userId);
  }
}
