import PrismaCommentRepository from "../../repositories/prisma_comment_repository";

export class DeleteCommentService {
  constructor(private readonly commentRepository: PrismaCommentRepository) {}

  async execute(commentID: string, userID: string) {
    if (!commentID) {
      throw new Error("Comment ID is required");
    }

    const existingComment = await this.commentRepository.findById(commentID);
    if (!existingComment) {
      throw new Error("Comment not found");
    }

    if (existingComment.userID !== userID) {
      throw new Error("Unauthorized to delete this comment");
    }

    return await this.commentRepository.delete(commentID);
  }
}
