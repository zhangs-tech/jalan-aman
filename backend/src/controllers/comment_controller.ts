import type { Request, Response, NextFunction } from "express";
import type { CreateCommentService } from "../services/comment/create_comment_service";
import type { GetCommentsByReportIdService } from "../services/comment/get_comments_by_report_service";
import type { UpdateCommentService } from "../services/comment/update_comment_service";

export class CommentController {
  constructor(
    private readonly createCommentService: CreateCommentService,
    private readonly getCommentsByReportIdService: GetCommentsByReportIdService,
    private readonly updateCommentService: UpdateCommentService
  ) {}

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ message: "Unauthorized" });
        return;
      }

      const { reportId } = req.params;
      const { details } = req.body;

      const data = {
        reportID: reportId as string,
        userID: req.user.id,
        details
      };

      const result = await this.createCommentService.execute(data);
      res.status(201).json({ message: "Comment created successfully", comment: result });
    } catch (error) {
      next(error as Error);
    }
  }

  async getByReportId(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { reportId } = req.params;
      const comments = await this.getCommentsByReportIdService.execute(reportId as string);
      res.status(200).json({ comments });
    } catch (error) {
      next(error as Error);
    }
  }

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ message: "Unauthorized" });
        return;
      }

      const { commentId } = req.params;
      const { details } = req.body;

      const result = await this.updateCommentService.execute(
        commentId as string,
        req.user.id,
        details
      );

      res.status(200).json({ message: "Comment updated successfully", comment: result });
    } catch (error) {
      next(error as Error);
    }
  }
}
