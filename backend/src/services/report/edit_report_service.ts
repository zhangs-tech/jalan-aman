import PrismaReportRepository from "../../repositories/prisma_report_repository";
import { ForbiddenError, NotFoundError, ConflictError } from "../../errors";
import { validateReportEdit } from "../../dtos/report-edit.dto";
import type { ReportEditResponse } from "../../dtos/report-edit.dto";
import type { ReportDTO } from "../../dtos/report-submit.dto";

const EARTH_RADIUS_M = 6_371_000;

// https://en.wikipedia.org/wiki/Haversine_formula
function haversineDistance(
  lat1: number, lng1: number,
  lat2: number, lng2: number
): number {
  const toRad = (deg: number) => (deg * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return EARTH_RADIUS_M * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

export class EditReportService {
  constructor(private readonly reportRepository: PrismaReportRepository) {}

  async execute(
    input: unknown,
    reportId: string,
    userId: string
  ): Promise<ReportEditResponse> {
    const { description, address, userLat, userLng } = validateReportEdit(input);

    const report = await this.reportRepository.findById(reportId);
    if (!report) {
      throw new NotFoundError("Report not found");
    }

    if (report.reportedBy !== userId) {
      throw new ForbiddenError("You can only edit your own reports");
    }

    const distance = haversineDistance(
      userLat,
      userLng,
      report.latitude,
      report.longitude
    );

    if (distance > 100) {
      throw new ConflictError("You must be within 100 meters of the report location to edit it");
    }

    const updated = await this.reportRepository.update(reportId, {
      description,
      address,
    });

    const reportDto: ReportDTO = {
      id: updated.id,
      reportType: updated.reportType,
      description: updated.description,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
      expiresAt: updated.expiresAt,
      reportedBy: updated.reportedBy,
      latitude: updated.latitude,
      longitude: updated.longitude,
      address: updated.address,
      zipCode: updated.zipCode,
    };

    return { report: reportDto };
  }
}
