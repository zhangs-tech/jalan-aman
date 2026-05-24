import PrismaCommentRepository from "../../repositories/prisma_comment_repository";
import { BadRequestError } from "../../errors";

export class GetCommentsByReportIdService {
  constructor(private readonly commentRepository: PrismaCommentRepository) {}

  async execute(reportID: string) {
    if (!reportID) {
      throw new BadRequestError("Report ID is required");
    }

    return await this.commentRepository.findByReportId(reportID);
  }
}
