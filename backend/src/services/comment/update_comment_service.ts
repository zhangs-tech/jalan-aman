import PrismaCommentRepository from "../../repositories/prisma_comment_repository";

export class UpdateCommentService {
  constructor(private readonly commentRepository: PrismaCommentRepository) {}

  async execute(commentID: string, userID: string, details: string) {
    if (!commentID || !details) {
      throw new Error("Comment ID and details are required");
    }

    const existingComment = await this.commentRepository.findById(commentID);
    if (!existingComment) {
      throw new Error("Comment not found");
    }

    if (existingComment.userID !== userID) {
      throw new Error("Unauthorized to edit this comment");
    }

    return await this.commentRepository.update(commentID, details);
  }
}
