import type { Request, Response } from "express";
import type { CreateReportService } from "../services/report/create_report_service";
import type { GetAllReportsService } from "../services/report/get_all_reports_service";
import type { GetReportByIdService } from "../services/report/get_report_by_id_service";
import type { UpdateReportStatusService } from "../services/report/update_report_status_service";
import type { GetReportsByUserService } from "../services/report/get_reports_by_user_service";
import { UnauthorizedError } from "../errors";

export class ReportController {
  constructor(
    private readonly createReportService: CreateReportService,
    private readonly getAllReportsService: GetAllReportsService,
    private readonly getReportByIdService: GetReportByIdService,
    private readonly updateReportStatusService: UpdateReportStatusService,
    private readonly getReportsByUserService: GetReportsByUserService
  ) { }

  async create(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new UnauthorizedError("Unauthorized");
    }

    const result = await this.createReportService.execute({
      ...req.body,
      reportedBy: req.user.id
    });

    res.status(201).json({ message: "Report created successfully", report: result });
  }

  async getAll(_req: Request, res: Response): Promise<void> {
    const reports = await this.getAllReportsService.execute();
    res.status(200).json({ reports });
  }

  async getByUser(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new UnauthorizedError("Unauthorized");
    }
    const reports = await this.getReportsByUserService.execute(req.user.id);
    res.status(200).json({ reports });
  }

  async getById(req: Request, res: Response): Promise<void> {
    const { id } = req.params;
    const report = await this.getReportByIdService.execute(id as string);
    res.status(200).json({ report });
  }

  async updateStatus(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new UnauthorizedError("Unauthorized");
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
  }
}
