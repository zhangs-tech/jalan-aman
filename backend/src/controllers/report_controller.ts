import type { Request, Response, NextFunction } from "express";
import type { CreateReportService } from "../services/report/create_report_service";
import type { GetAllReportsService } from "../services/report/get_all_reports_service";
import type { GetReportByIdService } from "../services/report/get_report_by_id_service";
import type { UpdateReportStatusService } from "../services/report/update_report_status_service";

export class ReportController {
  constructor(
    private readonly createReportService: CreateReportService,
    private readonly getAllReportsService: GetAllReportsService,
    private readonly getReportByIdService: GetReportByIdService,
    private readonly updateReportStatusService: UpdateReportStatusService
  ) { }

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ message: "Unauthorized" });
        return;
      }

      const data = {
        ...req.body,
        reportedBy: req.user.id
      };

      const result = await this.createReportService.execute(data);
      res.status(201).json({ message: "Report created successfully", report: result });
    } catch (error) {
      next(error as Error);
    }
  }

  async getAll(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const reports = await this.getAllReportsService.execute();
      res.status(200).json({ reports });
    } catch (error) {
      next(error as Error);
    }
  }

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const report = await this.getReportByIdService.execute(id as string);
      res.status(200).json({ report });
    } catch (error) {
      next(error as Error);
    }
  }

  async updateStatus(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ message: "Unauthorized" });
        return;
      }

      const { id } = req.params;
      const { status, details, imgB64 } = req.body;

      const result = await this.updateReportStatusService.execute(
        id as string,
        status,
        req.user.id,
        details,
        imgB64
      );

      res.status(200).json({ message: "Report status updated", report: result });
    } catch (error) {
      next(error as Error);
    }
  }
}
