import PrismaAttachmentRepository from "../../repositories/prisma_attachment_repository";
import { S3Service } from "../s3/s3_service";
import { NotFoundError } from "../../errors";
import type { AttachmentDownloadResponse } from "../../dtos/report-detail.dto";

export class GetAttachmentDownloadService {
  constructor(
    private readonly attachmentRepository: PrismaAttachmentRepository,
    private readonly s3Service: S3Service
  ) {}

  async execute(
    reportId: string,
    attachmentId: string
  ): Promise<AttachmentDownloadResponse> {
    const attachment = await this.attachmentRepository.findById(attachmentId);

    if (!attachment || attachment.report.id !== reportId) {
      throw new NotFoundError("Attachment not found");
    }

    const downloadUrl = await this.s3Service.generatePresignedDownloadUrl(
      attachment.s3Key,
      300
    );

    return { downloadUrl };
  }
}
