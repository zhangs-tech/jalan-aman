import PrismaReportRepository from "../../repositories/prisma_report_repository";
import { validateMapPinsParams } from "../../dtos/report-map.dto";
import type { MapPinsResponse, PinDTO } from "../../dtos/report-map.dto";

export class MapPinsService {
  constructor(private readonly reportRepository: PrismaReportRepository) {}

  async execute(query: unknown): Promise<MapPinsResponse> {
    const params = validateMapPinsParams(query);
    const result = await this.reportRepository.findPins({
      swLat: params.swLat,
      swLng: params.swLng,
      neLat: params.neLat,
      neLng: params.neLng,
      ...(params.reportType.length > 0 ? { reportType: params.reportType } : {}),
    });

    const pins: PinDTO[] = result.map((row) => ({
      id: row.id,
      reportType: row.reportType,
      latitude: row.latitude,
      longitude: row.longitude,
    }));

    return { pins };
  }
}
