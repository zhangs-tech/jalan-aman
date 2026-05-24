import type { PrismaClient } from "../generated/prisma/client";

export type CreateReportData = {
  reportType: string;
  description: string;
  latitude: number;
  longitude: number;
  address: string;
  zipCode?: string;
  expiresAt: Date;
  reportedBy: string;
  attachment?: {
    s3Key: string;
    mimeType: string;
    fileSize: number;
  };
};

export type AttachmentDTO = {
  id: string;
  reportId: string;
  s3Key: string;
  mimeType: string;
  fileSize: number;
  createdAt: Date;
};

export type ReportDTO = {
  id: string;
  reportType: string;
  description: string;
  createdAt: Date;
  updatedAt: Date;
  expiresAt: Date;
  deletedAt: Date | null;
  reportedBy: string;
  latitude: number;
  longitude: number;
  address: string;
  zipCode: string | null;
  attachments: AttachmentDTO[];
};

export default class PrismaReportRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async create(data: CreateReportData): Promise<ReportDTO> {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const createData: Record<string, any> = {
      reportType: data.reportType,
      description: data.description,
      latitude: data.latitude,
      longitude: data.longitude,
      address: data.address,
      expiresAt: data.expiresAt,
      reportedBy: data.reportedBy,
    };

    if (data.zipCode !== undefined) {
      createData.zipCode = data.zipCode;
    }

    if (data.attachment) {
      createData.attachments = {
        create: {
          s3Key: data.attachment.s3Key,
          mimeType: data.attachment.mimeType,
          fileSize: data.attachment.fileSize,
        },
      };
    }

    return (await this.prisma.report.create({
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      data: createData as any,
      include: { attachments: true },
    })) as ReportDTO;
  }

  async findById(id: string) {
    return (await this.prisma.report.findUnique({
      where: { id },
    })) as ReportDTO | null;
  }

  async softDelete(id: string): Promise<void> {
    await this.prisma.report.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }

  async update(id: string, data: { description: string; address: string }): Promise<ReportDTO> {
    return (await this.prisma.report.update({
      where: { id },
      data: {
        description: data.description,
        address: data.address,
      },
    })) as ReportDTO;
  }
}
