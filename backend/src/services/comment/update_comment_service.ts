import PrismaCommentRepository from "../../repositories/prisma_comment_repository";
import { BadRequestError, NotFoundError, UnauthorizedError } from "../../errors";

export class UpdateCommentService {
  constructor(private readonly commentRepository: PrismaCommentRepository) {}

  async execute(commentID: string, userID: string, details: string) {
    if (!commentID || !details) {
      throw new BadRequestError("Comment ID and details are required");
    }

    const existingComment = await this.commentRepository.findById(commentID);
    if (!existingComment) {
      throw new NotFoundError("Comment not found");
    }

    if (existingComment.userID !== userID) {
      throw new UnauthorizedError("Unauthorized to edit this comment");
    }

    return await this.commentRepository.update(commentID, details);
  }
}
