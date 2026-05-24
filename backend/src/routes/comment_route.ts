import { Router } from "express";
import { CommentController } from "../controllers/comment_controller";
import prisma from "../prisma";
import PrismaCommentRepository from "../repositories/prisma_comment_repository";
import PrismaReportRepository from "../repositories/prisma_report_repository";
import { CreateCommentService } from "../services/comment/create_comment_service";
import { GetCommentsByReportIdService } from "../services/comment/get_comments_by_report_service";
import { UpdateCommentService } from "../services/comment/update_comment_service";
import { DeleteCommentService } from "../services/comment/delete_comment_service";
import { authMiddleware } from "../middlewares/auth_middleware";

const commentRepository = new PrismaCommentRepository(prisma);
const reportRepository = new PrismaReportRepository(prisma);
const createCommentService = new CreateCommentService(commentRepository, reportRepository);
const getCommentsByReportIdService = new GetCommentsByReportIdService(commentRepository, reportRepository);
const updateCommentService = new UpdateCommentService(commentRepository);
const deleteCommentService = new DeleteCommentService(commentRepository);

const commentController = new CommentController(
  createCommentService,
  getCommentsByReportIdService,
  updateCommentService,
  deleteCommentService
);

export const commentRouter = Router({ mergeParams: true });

commentRouter.post("/", authMiddleware, (req, res) =>
  commentController.create(req, res)
);

commentRouter.get("/", (req, res) =>
  commentController.getByReportId(req, res)
);

commentRouter.patch("/:commentId", authMiddleware, (req, res) =>
  commentController.update(req, res)
);

commentRouter.delete("/:commentId", authMiddleware, (req, res) =>
  commentController.delete(req, res)
);
