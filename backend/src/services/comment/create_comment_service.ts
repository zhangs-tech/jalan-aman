import PrismaCommentRepository from "../../repositories/prisma_comment_repository";
import { BadRequestError } from "../../errors";

export class CreateCommentService {
  constructor(private readonly commentRepository: PrismaCommentRepository) {}

  async execute(data: { reportID: string; userID: string; details: string }) {
    if (!data.reportID || !data.userID || !data.details) {
      throw new BadRequestError("Missing required fields for comment creation.");
    }

    return await this.commentRepository.create({
      details: data.details,
      report: { connect: { reportID: data.reportID } },
      user: { connect: { id: data.userID } },
    });
  }
}
