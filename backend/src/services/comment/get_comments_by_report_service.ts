import PrismaCommentRepository from "../../repositories/prisma_comment_repository";
import { BadRequestError } from "../../errors";

export class GetCommentsByReportIdService {
  constructor(private readonly commentRepository: PrismaCommentRepository) {}

  async execute(reportId: string) {
    if (!reportId) {
      throw new BadRequestError("Report ID is required");
    }

    return await this.commentRepository.findByReportId(reportId);
  }
}
