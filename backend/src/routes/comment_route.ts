import { Router } from "express";
import { CommentController } from "../controllers/comment_controller";
import prisma from "../prisma";
import PrismaCommentRepository from "../repositories/prisma_comment_repository";
import { CreateCommentService } from "../services/comment/create_comment_service";
import { GetCommentsByReportIdService } from "../services/comment/get_comments_by_report_service";
import { UpdateCommentService } from "../services/comment/update_comment_service";
import { authMiddleware } from "../middlewares/auth_middleware";

const commentRepository = new PrismaCommentRepository(prisma);
const createCommentService = new CreateCommentService(commentRepository);
const getCommentsByReportIdService = new GetCommentsByReportIdService(commentRepository);
const updateCommentService = new UpdateCommentService(commentRepository);

const commentController = new CommentController(
  createCommentService,
  getCommentsByReportIdService,
  updateCommentService
);

export const commentRouter = Router({ mergeParams: true });

commentRouter.post("/", authMiddleware, (req, res, next) =>
  commentController.create(req, res, next)
);

commentRouter.get("/", authMiddleware, (req, res, next) =>
  commentController.getByReportId(req, res, next)
);

commentRouter.patch("/:commentId", authMiddleware, (req, res, next) =>
  commentController.update(req, res, next)
);
