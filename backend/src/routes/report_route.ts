import { Router } from "express";
import { ReportController } from "../controllers/report_controller";
import prisma from "../prisma";
import PrismaReportRepository from "../repositories/prisma_report_repository";
import PrismaVoteRepository from "../repositories/prisma_vote_repository";
import { CreateReportService } from "../services/report/create_report_service";
import { EditReportService } from "../services/report/edit_report_service";
import { DeleteReportService } from "../services/report/delete_report_service";
import { VoteReportService } from "../services/report/vote_report_service";
import { S3Service } from "../services/s3/s3_service";
import { authMiddleware } from "../middlewares/auth_middleware";

const reportRepository = new PrismaReportRepository(prisma);
const voteRepository = new PrismaVoteRepository(prisma);
const s3Service = new S3Service();
const createReportService = new CreateReportService(reportRepository, s3Service);
const editReportService = new EditReportService(reportRepository);
const deleteReportService = new DeleteReportService(reportRepository);
const voteReportService = new VoteReportService(reportRepository, voteRepository);

const reportController = new ReportController(createReportService, editReportService, deleteReportService, voteReportService);

export const reportRouter = Router();

reportRouter.post("/", authMiddleware, (req, res) =>
  reportController.create(req, res)
);
reportRouter.get("/", authMiddleware, (req, res) =>
  reportController.getAll(req, res)
);
reportRouter.get("/user/me", authMiddleware, (req, res) =>
  reportController.getByUser(req, res)
);
reportRouter.get("/:id", authMiddleware, (req, res) =>
  reportController.getById(req, res)
);
reportRouter.put("/:id", authMiddleware, (req, res) =>
  reportController.edit(req, res)
);
reportRouter.delete("/:id", authMiddleware, (req, res) =>
  reportController.delete(req, res)
);
reportRouter.patch("/:id/status", authMiddleware, (req, res) =>
  reportController.updateStatus(req, res)
);
reportRouter.post("/:reportId/confirm", authMiddleware, (req, res) =>
  reportController.confirm(req, res)
);
reportRouter.post("/:reportId/resolve", authMiddleware, (req, res) =>
  reportController.resolve(req, res)
);
reportRouter.post("/:reportId/attachments/:attachmentId/confirm", authMiddleware, (req, res) =>
  reportController.confirmAttachment(req, res)
);
