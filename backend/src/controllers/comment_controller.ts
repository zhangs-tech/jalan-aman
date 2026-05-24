import type { Request, Response } from "express";
import type { CreateCommentService } from "../services/comment/create_comment_service";
import type { GetCommentsByReportIdService } from "../services/comment/get_comments_by_report_service";
import type { UpdateCommentService } from "../services/comment/update_comment_service";
import type { DeleteCommentService } from "../services/comment/delete_comment_service";
import { UnauthorizedError } from "../errors";

export class CommentController {
  constructor(
    private readonly createCommentService: CreateCommentService,
    private readonly getCommentsByReportIdService: GetCommentsByReportIdService,
    private readonly updateCommentService: UpdateCommentService,
    private readonly deleteCommentService: DeleteCommentService
  ) {}

  async create(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new UnauthorizedError("Unauthorized");
    }

    const { reportId } = req.params;

    const result = await this.createCommentService.execute(
      req.body,
      reportId as string,
      req.user.id
    );

    res.status(201).json(result);
  }

  async getByReportId(req: Request, res: Response): Promise<void> {
    const { reportId } = req.params;
    const result = await this.getCommentsByReportIdService.execute(
      reportId as string,
      req.query
    );
    res.status(200).json(result);
  }

  async update(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new UnauthorizedError("Unauthorized");
    }

    const { commentId } = req.params;
    const { details } = req.body;

    const result = await this.updateCommentService.execute(
      commentId as string,
      req.user.id,
      details
    );

    res.status(200).json({ message: "Comment updated successfully", comment: result });
  }

  async delete(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new UnauthorizedError("Unauthorized");
    }

    const { commentId } = req.params;

    await this.deleteCommentService.execute(
      commentId as string,
      req.user.id
    );

    res.status(200).json({ message: "Comment deleted successfully" });
  }
}
