import { Router } from "express";
import { ReportController } from "../controllers/report_controller";
import prisma from "../prisma";
import PrismaReportRepository from "../repositories/prisma_report_repository";
import { CreateReportService } from "../services/report/create_report_service";
import { GetAllReportsService } from "../services/report/get_all_reports_service";
import { GetReportByIdService } from "../services/report/get_report_by_id_service";
import { UpdateReportStatusService } from "../services/report/update_report_status_service";
import { authMiddleware } from "../middlewares/auth_middleware";

const reportRepository = new PrismaReportRepository(prisma);
const createReportService = new CreateReportService(reportRepository);
const getAllReportsService = new GetAllReportsService(reportRepository);
const getReportByIdService = new GetReportByIdService(reportRepository);
const updateReportStatusService = new UpdateReportStatusService(reportRepository);

const reportController = new ReportController(
  createReportService,
  getAllReportsService,
  getReportByIdService,
  updateReportStatusService
);

export const reportRouter = Router();

reportRouter.post("/", authMiddleware, (req, res, next) =>
  reportController.create(req, res, next)
);
reportRouter.get("/", authMiddleware, (req, res, next) =>
  reportController.getAll(req, res, next)
);
reportRouter.get("/:id", authMiddleware, (req, res, next) =>
  reportController.getById(req, res, next)
);
reportRouter.patch("/:id/status", authMiddleware, (req, res, next) =>
  reportController.updateStatus(req, res, next)
);
