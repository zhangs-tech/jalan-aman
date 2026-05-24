import PrismaCommentRepository from "../../repositories/prisma_comment_repository";
import { BadRequestError } from "../../errors";

export class CreateCommentService {
  constructor(private readonly commentRepository: PrismaCommentRepository) {}

  async execute(data: { reportId: string; userId: string; details: string }) {
    if (!data.reportId || !data.userId || !data.details) {
      throw new BadRequestError("Missing required fields for comment creation.");
    }

    return await this.commentRepository.create({
      details: data.details,
      reportId: data.reportId,
      userId: data.userId,
    });
  }
}
