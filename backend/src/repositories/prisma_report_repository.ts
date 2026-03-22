import type { PrismaClient, Prisma } from "../generated/prisma/client";

export default class PrismaReportRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async create(data: Prisma.ReportCreateInput) {
    return await this.prisma.report.create({ data });
  }

  async findAll() {
    return await this.prisma.report.findMany({
      orderBy: { reportedAt: 'desc' },
      include: {
        user: {
          select: { id: true, name: true, email: true }
        }
      }
    });
  }

  async findById(reportID: string) {
    return await this.prisma.report.findUnique({
      where: { reportID },
      include: {
        user: { select: { id: true, name: true, email: true } },
        history: {
          include: {
            user: { select: { id: true, name: true } }
          }
        },
        comments: {
          orderBy: { createdAt: 'desc' },
          include: {
            user: { select: { id: true, name: true } }
          }
        }
      }
    });
  }

  async updateStatus(reportID: string, newStatus: string, changedBy: string, details: string, imgB64?: string) {
    return await this.prisma.$transaction(async (tx) => {
      const report = await tx.report.findUnique({ where: { reportID } });
      if (!report) throw new Error("Report not found");

      const oldStatus = report.status;

      const updatedReport = await tx.report.update({
        where: { reportID },
        data: { status: newStatus }
      });

      await tx.reportHistory.create({
        data: {
          reportID,
          changedBy,
          oldStatus,
          newStatus,
          details,
          imgB64: imgB64 || report.imgB64
        }
      });

      return updatedReport;
    });
  }
}
