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
};

export type CreateReportResult = ReportDTO & {
  attachments: AttachmentDTO[];
};

export type ReportWithVotes = ReportDTO & {
  votes: Array<{ type: string; userId: string }>;
};

export type ReportListResult = {
  reports: ReportWithVotes[];
  nextCursor: string | null;
};

export type PinResult = {
  id: string;
  reportType: string;
  latitude: number;
  longitude: number;
};

export type ReportDetailResult = ReportDTO & {
  attachments: AttachmentDTO[];
  votes: Array<{ type: string; userId: string }>;
  _count: { comments: number };
};

export default class PrismaReportRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async create(data: CreateReportData): Promise<CreateReportResult> {
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
    })) as CreateReportResult;
  }

  async findById(id: string) {
    return (await this.prisma.report.findUnique({
      where: { id },
    })) as ReportDTO | null;
  }

  async findDetailById(id: string): Promise<ReportDetailResult | null> {
    return (await this.prisma.report.findUnique({
      where: { id },
      include: {
        attachments: true,
        votes: {
          select: { type: true, userId: true },
        },
        _count: {
          select: { comments: true },
        },
      },
    })) as ReportDetailResult | null;
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

  async findMany(params: {
    cursor?: string;
    limit: number;
    reportType?: string[];
    sort: "createdAt" | "expiresAt";
    order: "asc" | "desc";
  }): Promise<ReportListResult> {
    const now = new Date();
    const take = params.limit + 1;

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const where: Record<string, any> = {
      deletedAt: null,
      expiresAt: { gt: now },
    };

    if (params.reportType && params.reportType.length > 0) {
      where.reportType = { in: params.reportType };
    }

    if (params.cursor) {
      const cursorValue = new Date(Buffer.from(params.cursor, "base64").toString("utf-8"));
      where[params.sort] = {
        [params.order === "asc" ? "gt" : "lt"]: cursorValue,
      };
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const rows = (await this.prisma.report.findMany({
      where: where as any,
      orderBy: { [params.sort]: params.order },
      take,
      include: {
        votes: {
          select: { type: true, userId: true },
        },
      },
    })) as ReportWithVotes[];

    const hasMore = rows.length > params.limit;
    const reports = hasMore ? rows.slice(0, params.limit) : rows;
    const nextCursor = hasMore
      ? Buffer.from(reports[reports.length - 1]![params.sort].toISOString()).toString("base64")
      : null;

    return { reports, nextCursor };
  }

  async findPins(params: {
    swLat: number;
    swLng: number;
    neLat: number;
    neLng: number;
    reportType?: string[];
  }): Promise<PinResult[]> {
    const now = new Date();

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const where: Record<string, any> = {
      deletedAt: null,
      expiresAt: { gt: now },
      latitude: { gte: params.swLat, lte: params.neLat },
      longitude: { gte: params.swLng, lte: params.neLng },
    };

    if (params.reportType && params.reportType.length > 0) {
      where.reportType = { in: params.reportType };
    }

    return (await this.prisma.report.findMany({
      where: where as any,
      select: {
        id: true,
        reportType: true,
        latitude: true,
        longitude: true,
      },
      take: 500,
    })) as PinResult[];
  }
}
