import PrismaCommentRepository from "../../repositories/prisma_comment_repository";
import { BadRequestError, NotFoundError, UnauthorizedError } from "../../errors";

export class DeleteCommentService {
  constructor(private readonly commentRepository: PrismaCommentRepository) {}

  async execute(commentID: string, userID: string) {
    if (!commentID) {
      throw new BadRequestError("Comment ID is required");
    }

    const existingComment = await this.commentRepository.findById(commentID);
    if (!existingComment) {
      throw new NotFoundError("Comment not found");
    }

    if (existingComment.userID !== userID) {
      throw new UnauthorizedError("Unauthorized to delete this comment");
    }

    return await this.commentRepository.delete(commentID);
  }
}
