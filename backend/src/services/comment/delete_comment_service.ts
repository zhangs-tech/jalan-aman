import PrismaCommentRepository from "../../repositories/prisma_comment_repository";
import { BadRequestError, NotFoundError, UnauthorizedError } from "../../errors";

export class DeleteCommentService {
  constructor(private readonly commentRepository: PrismaCommentRepository) {}

  async execute(commentId: string, userId: string) {
    if (!commentId) {
      throw new BadRequestError("Comment ID is required");
    }

    const existingComment = await this.commentRepository.findById(commentId);
    if (!existingComment) {
      throw new NotFoundError("Comment not found");
    }

    if (existingComment.userId !== userId) {
      throw new UnauthorizedError("Unauthorized to delete this comment");
    }

    return await this.commentRepository.delete(commentId);
  }
}
