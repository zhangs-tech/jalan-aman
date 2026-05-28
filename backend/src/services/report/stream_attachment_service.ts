import PrismaAttachmentRepository from "../../repositories/prisma_attachment_repository";
import { S3Service } from "../s3/s3_service";
import { NotFoundError } from "../../errors";

export type StreamAttachmentResult = {
  stream: ReadableStream;
  mimeType: string;
  fileSize: number;
};

export class StreamAttachmentService {
  constructor(
    private readonly attachmentRepository: PrismaAttachmentRepository,
    private readonly s3Service: S3Service
  ) {}

  async execute(
    reportId: string,
    attachmentId: string
  ): Promise<StreamAttachmentResult> {
    const attachment = await this.attachmentRepository.findById(attachmentId);

    if (!attachment || attachment.report.id !== reportId) {
      throw new NotFoundError("Attachment not found");
    }

    const stream = await this.s3Service.getObjectStream(attachment.s3Key);

    return {
      stream,
      mimeType: attachment.mimeType,
      fileSize: attachment.fileSize,
    };
  }
}
