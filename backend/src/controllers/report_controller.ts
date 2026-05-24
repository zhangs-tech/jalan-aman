import type { Request, Response } from "express";
import type { CreateReportService } from "../services/report/create_report_service";
import type { EditReportService } from "../services/report/edit_report_service";
import type { DeleteReportService } from "../services/report/delete_report_service";
import type { VoteReportService } from "../services/report/vote_report_service";
import type { ListReportsService } from "../services/report/list_reports_service";
import type { MapPinsService } from "../services/report/map_pins_service";
import JwtService from "../services/auth/jwt_service";
import { UnauthorizedError } from "../errors";

const jwtService = new JwtService();

export class ReportController {
  constructor(
    private readonly createReportService: CreateReportService,
    private readonly editReportService: EditReportService,
    private readonly deleteReportService: DeleteReportService,
    private readonly voteReportService: VoteReportService,
    private readonly listReportsService: ListReportsService,
    private readonly mapPinsService: MapPinsService
  ) {}

  async create(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new UnauthorizedError("Unauthorized");
    }

    const result = await this.createReportService.execute(req.body, req.user.id);

    res.status(201).json(result);
  }

  async getAll(req: Request, res: Response): Promise<void> {
    const userId = await this.tryGetUserId(req);
    const result = await this.listReportsService.execute(req.query, userId);

    res.status(200).json(result);
  }

  async getByUser(_req: Request, res: Response): Promise<void> {
    // TODO: implement in future use case
    res.status(501).json({ message: "Not implemented" });
  }

  async getById(_req: Request, res: Response): Promise<void> {
    // TODO: implement in future use case
    res.status(501).json({ message: "Not implemented" });
  }

  async getMap(req: Request, res: Response): Promise<void> {
    const result = await this.mapPinsService.execute(req.query);

    res.status(200).json(result);
  }

  async updateStatus(_req: Request, res: Response): Promise<void> {
    // TODO: implement in future use case
    res.status(501).json({ message: "Not implemented" });
  }

  async confirmAttachment(_req: Request, res: Response): Promise<void> {
    // TODO: implement in future use case (kept for backward compatibility)
    res.status(501).json({ message: "Not implemented" });
  }

  async delete(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new UnauthorizedError("Unauthorized");
    }

    const { id } = req.params;
    await this.deleteReportService.execute(id as string, req.user.id);

    res.status(200).json({ message: "Report deleted" });
  }

  async edit(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new UnauthorizedError("Unauthorized");
    }

    const { id } = req.params;
    const result = await this.editReportService.execute(req.body, id as string, req.user.id);

    res.status(200).json(result);
  }

  async confirm(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new UnauthorizedError("Unauthorized");
    }

    const { reportId } = req.params;
    const result = await this.voteReportService.execute(reportId as string, req.user.id, "confirm");

    res.status(200).json(result);
  }

  async resolve(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new UnauthorizedError("Unauthorized");
    }

    const { reportId } = req.params;
    const result = await this.voteReportService.execute(reportId as string, req.user.id, "resolve");

    res.status(200).json(result);
  }

  private async tryGetUserId(req: Request): Promise<string | undefined> {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith("Bearer ")) return undefined;

    try {
      const token = authHeader.split(" ")[1]!;
      const decoded = await jwtService.verify(token);
      return decoded.id;
    } catch {
      return undefined;
    }
  }
}
