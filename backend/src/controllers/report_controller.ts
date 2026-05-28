import type { Request, Response } from "express";
import type { CreateReportService } from "../services/report/create_report_service";
import type { EditReportService } from "../services/report/edit_report_service";
import type { DeleteReportService } from "../services/report/delete_report_service";
import type { VoteReportService } from "../services/report/vote_report_service";
import type { ListReportsService } from "../services/report/list_reports_service";
import type { MapPinsService } from "../services/report/map_pins_service";
import type { GetReportDetailService } from "../services/report/get_report_detail_service";
import type { GetAttachmentDownloadService } from "../services/report/get_attachment_download_service";
import type { StreamAttachmentService } from "../services/report/stream_attachment_service";
import type { GetReportsByUserService } from "../services/report/get_reports_by_user_service";
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
    private readonly mapPinsService: MapPinsService,
    private readonly getReportDetailService: GetReportDetailService,
    private readonly getAttachmentDownloadService: GetAttachmentDownloadService,
    private readonly getReportsByUserService: GetReportsByUserService,
    private readonly streamAttachmentService: StreamAttachmentService
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

  async getByUser(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new UnauthorizedError("Unauthorized");
    }

    const result = await this.getReportsByUserService.execute(req.query, req.user.id);

    res.status(200).json(result);
  }

  async getById(req: Request, res: Response): Promise<void> {
    const userId = await this.tryGetUserId(req);
    const { id } = req.params;
    const result = await this.getReportDetailService.execute(id as string, userId);

    res.status(200).json(result);
  }

  async downloadAttachment(req: Request, res: Response): Promise<void> {
    const { reportId, attachmentId } = req.params;
    const result = await this.getAttachmentDownloadService.execute(
      reportId as string,
      attachmentId as string
    );

    res.status(200).json(result);
  }

  async streamAttachment(req: Request, res: Response): Promise<void> {
    const { reportId, attachmentId } = req.params;
    const { stream, mimeType, fileSize } = await this.streamAttachmentService.execute(
      reportId as string,
      attachmentId as string
    );

    res.setHeader("Content-Type", mimeType);
    res.setHeader("Content-Length", fileSize);
    res.setHeader("Cache-Control", "private, max-age=3600, immutable");
    res.status(200);

    const reader = stream.getReader();
    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        res.write(value);
      }
      res.end();
    } catch {
      reader.cancel();
      if (!res.headersSent) {
        res.status(500).json({ message: "Failed to stream attachment" });
      }
    }
  }

  async getMap(req: Request, res: Response): Promise<void> {
    const result = await this.mapPinsService.execute(req.query);

    res.status(200).json(result);
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
