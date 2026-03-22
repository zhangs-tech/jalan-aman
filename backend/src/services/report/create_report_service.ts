import PrismaReportRepository from "../../repositories/prisma_report_repository";

export class CreateReportService {
  constructor(private readonly reportRepository: PrismaReportRepository) {}

  async execute(data: {
    status: string;
    description: string;
    imgB64: string;
    reportedBy: string;
    latitude: number;
    longitude: number;
    address: string;
    zipCode: string;
  }) {
    if (!data.description || !data.latitude || !data.longitude || !data.address) {
      throw new Error("Missing required fields for report creation.");
    }

    return await this.reportRepository.create({
      status: data.status || "Pending",
      description: data.description,
      imgB64: data.imgB64 || "",
      latitude: data.latitude,
      longitude: data.longitude,
      address: data.address,
      zipCode: data.zipCode,
      user: {
        connect: { id: data.reportedBy }
      }
    });
  }
}
