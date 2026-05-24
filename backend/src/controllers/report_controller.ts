import type { Request, Response } from "express";
import type { CreateReportService } from "../services/report/create_report_service";
import { UnauthorizedError } from "../errors";

export class ReportController {
  constructor(
    private readonly createReportService: CreateReportService
  ) {}

  async create(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new UnauthorizedError("Unauthorized");
    }

    const result = await this.createReportService.execute(req.body, req.user.id);

    res.status(201).json(result);
  }

  async getAll(_req: Request, res: Response): Promise<void> {
    // TODO: implement in future use case
    res.status(501).json({ message: "Not implemented" });
  }

  async getByUser(_req: Request, res: Response): Promise<void> {
    // TODO: implement in future use case
    res.status(501).json({ message: "Not implemented" });
  }

  async getById(_req: Request, res: Response): Promise<void> {
    // TODO: implement in future use case
    res.status(501).json({ message: "Not implemented" });
  }

  async updateStatus(_req: Request, res: Response): Promise<void> {
    // TODO: implement in future use case
    res.status(501).json({ message: "Not implemented" });
  }

  async confirmAttachment(_req: Request, res: Response): Promise<void> {
    // TODO: implement in future use case (kept for backward compatibility)
    res.status(501).json({ message: "Not implemented" });
  }
}
