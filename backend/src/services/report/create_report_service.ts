import PrismaReportRepository from "../../repositories/prisma_report_repository";
import { S3Service } from "../s3/s3_service";
import type {
  ReportDTO,
  ReportSubmitResponse,
} from "../../dtos/report-submit.dto";
import { TTL_HOURS, validateReportSubmit } from "../../dtos/report-submit.dto";

export class CreateReportService {
  constructor(
    private readonly reportRepository: PrismaReportRepository,
    private readonly s3Service: S3Service
  ) {}

  async execute(input: unknown, reportedBy: string): Promise<ReportSubmitResponse> {
    const dto = validateReportSubmit(input);

    const ttlHours = TTL_HOURS[dto.reportType]!;
    const expiresAt = new Date(Date.now() + ttlHours * 60 * 60 * 1000);

    let attachmentMeta:
      | { s3Key: string; mimeType: string; fileSize: number }
      | undefined;

    if (dto.attachment) {
      const s3Key = `reports/${crypto.randomUUID()}/${dto.attachment.mimeType.split("/")[1] || "file"}`;
      attachmentMeta = {
        s3Key,
        mimeType: dto.attachment.mimeType,
        fileSize: dto.attachment.fileSize,
      };
    }

    const createParams: Parameters<typeof this.reportRepository.create>[0] = {
      reportType: dto.reportType,
      description: dto.description,
      latitude: dto.latitude,
      longitude: dto.longitude,
      address: dto.address,
      expiresAt,
      reportedBy,
    };

    if (dto.zipCode !== undefined) {
      createParams.zipCode = dto.zipCode;
    }

    if (attachmentMeta !== undefined) {
      createParams.attachment = attachmentMeta;
    }

    const result = await this.reportRepository.create(createParams);

    const report: ReportDTO = {
      id: result.id,
      reportType: result.reportType,
      description: result.description,
      createdAt: result.createdAt,
      updatedAt: result.updatedAt,
      expiresAt: result.expiresAt,
      reportedBy: result.reportedBy,
      latitude: result.latitude,
      longitude: result.longitude,
      address: result.address,
      zipCode: result.zipCode,
    };

    const response: ReportSubmitResponse = { report };

    if (result.attachments.length > 0 && attachmentMeta) {
      const att = result.attachments[0]!;
      const uploadUrl = await this.s3Service.generatePresignedUploadUrl(
        att.s3Key,
        att.mimeType
      );
      response.attachment = {
        id: att.id,
        uploadUrl,
        s3Key: att.s3Key,
        mimeType: att.mimeType,
        fileSize: att.fileSize,
        createdAt: att.createdAt,
      };
    }

    return response;
  }
}
