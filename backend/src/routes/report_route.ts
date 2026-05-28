import { Router } from "express";
import { ReportController } from "../controllers/report_controller";
import prisma from "../prisma";
import PrismaReportRepository from "../repositories/prisma_report_repository";
import PrismaVoteRepository from "../repositories/prisma_vote_repository";
import PrismaAttachmentRepository from "../repositories/prisma_attachment_repository";
import { CreateReportService } from "../services/report/create_report_service";
import { EditReportService } from "../services/report/edit_report_service";
import { DeleteReportService } from "../services/report/delete_report_service";
import { VoteReportService } from "../services/report/vote_report_service";
import { ListReportsService } from "../services/report/list_reports_service";
import { MapPinsService } from "../services/report/map_pins_service";
import { GetReportDetailService } from "../services/report/get_report_detail_service";
import { GetAttachmentDownloadService } from "../services/report/get_attachment_download_service";
import { StreamAttachmentService } from "../services/report/stream_attachment_service";
import { GetReportsByUserService } from "../services/report/get_reports_by_user_service";
import { S3Service } from "../services/s3/s3_service";
import { authMiddleware } from "../middlewares/auth_middleware";

const reportRepository = new PrismaReportRepository(prisma);
const voteRepository = new PrismaVoteRepository(prisma);
const attachmentRepository = new PrismaAttachmentRepository(prisma);
const s3Service = new S3Service();
const createReportService = new CreateReportService(reportRepository, s3Service);
const editReportService = new EditReportService(reportRepository);
const deleteReportService = new DeleteReportService(reportRepository);
const voteReportService = new VoteReportService(reportRepository, voteRepository);
const listReportsService = new ListReportsService(reportRepository);
const mapPinsService = new MapPinsService(reportRepository);
const getReportDetailService = new GetReportDetailService(reportRepository);
const getAttachmentDownloadService = new GetAttachmentDownloadService(attachmentRepository, s3Service);
const streamAttachmentService = new StreamAttachmentService(attachmentRepository, s3Service);
const getReportsByUserService = new GetReportsByUserService(reportRepository);

const reportController = new ReportController(
  createReportService,
  editReportService,
  deleteReportService,
  voteReportService,
  listReportsService,
  mapPinsService,
  getReportDetailService,
  getAttachmentDownloadService,
  getReportsByUserService,
  streamAttachmentService
);

export const reportRouter = Router();

reportRouter.post("/", authMiddleware, (req, res) =>
  reportController.create(req, res)
);
reportRouter.get("/", (req, res) =>
  reportController.getAll(req, res)
);
reportRouter.get("/map", (req, res) =>
  reportController.getMap(req, res)
);
reportRouter.get("/user/me", authMiddleware, (req, res) =>
  reportController.getByUser(req, res)
);
reportRouter.get("/:id", (req, res) =>
  reportController.getById(req, res)
);
reportRouter.get("/:reportId/attachments/:attachmentId/download", (req, res) =>
  reportController.downloadAttachment(req, res)
);
reportRouter.get("/:reportId/attachments/:attachmentId", (req, res) =>
  reportController.streamAttachment(req, res)
);
reportRouter.put("/:id", authMiddleware, (req, res) =>
  reportController.edit(req, res)
);
reportRouter.delete("/:id", authMiddleware, (req, res) =>
  reportController.delete(req, res)
);
reportRouter.post("/:reportId/confirm", authMiddleware, (req, res) =>
  reportController.confirm(req, res)
);
reportRouter.post("/:reportId/resolve", authMiddleware, (req, res) =>
  reportController.resolve(req, res)
);
