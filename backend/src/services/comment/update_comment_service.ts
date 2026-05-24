import PrismaCommentRepository from "../../repositories/prisma_comment_repository";
import { BadRequestError, NotFoundError, UnauthorizedError } from "../../errors";

export class UpdateCommentService {
  constructor(private readonly commentRepository: PrismaCommentRepository) {}

  async execute(commentId: string, userId: string, details: string) {
    if (!commentId || !details) {
      throw new BadRequestError("Comment ID and details are required");
    }

    const existingComment = await this.commentRepository.findById(commentId);
    if (!existingComment) {
      throw new NotFoundError("Comment not found");
    }

    if (existingComment.userId !== userId) {
      throw new UnauthorizedError("Unauthorized to edit this comment");
    }

    return await this.commentRepository.update(commentId, details);
  }
}
