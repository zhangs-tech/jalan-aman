// DTOs for "Submit Report" use case
// See: docs/use_cases/submit_report_use_case.md

import { BadRequestError, UnprocessableEntityError } from "../errors";

// ---------------------------------------------------------------------------
// Request DTOs
// ---------------------------------------------------------------------------

export type AttachmentMetaDTO = {
  mimeType: string;
  fileSize: number;
};

export type ReportSubmitDTO = {
  reportType: string;
  description: string;
  latitude: number;
  longitude: number;
  address: string;
  zipCode?: string;
  attachment?: AttachmentMetaDTO;
};

// ---------------------------------------------------------------------------
// Response DTOs
// ---------------------------------------------------------------------------

export type ReportDTO = {
  id: string;
  reportType: string;
  description: string;
  createdAt: Date;
  updatedAt: Date;
  expiresAt: Date;
  reportedBy: string;
  latitude: number;
  longitude: number;
  address: string;
  zipCode: string | null;
};

export type AttachmentUploadDTO = {
  id: string;
  uploadUrl: string;
  s3Key: string;
  mimeType: string;
  fileSize: number;
  createdAt: Date;
};

export type ReportSubmitResponse = {
  report: ReportDTO;
  attachment?: AttachmentUploadDTO;
};

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------

export const VALID_REPORT_TYPES = new Set([
  "accident",
  "police",
  "hazard",
  "crime",
  "flood",
  "pothole",
  "closure",
  "construction",
  "broken_traffic_light",
  "other",
]);

export const TTL_HOURS: Record<string, number> = {
  accident: 2,
  police: 2,
  hazard: 2,
  crime: 2,
  flood: 12,
  pothole: 12,
  closure: 24,
  construction: 24,
  broken_traffic_light: 24,
  other: 6,
};

export function validateReportSubmit(input: unknown): ReportSubmitDTO {
  if (typeof input !== "object" || input === null) {
    throw new BadRequestError("Request body must be a JSON object");
  }

  const body = input as Record<string, unknown>;

  const reportType = body.reportType;
  const description = body.description;
  const latitude = body.latitude;
  const longitude = body.longitude;
  const address = body.address;

  if (reportType == null || description == null || latitude == null || longitude == null || address == null) {
    throw new BadRequestError(
      "Missing required fields: reportType, description, latitude, longitude, address"
    );
  }

  if (typeof reportType !== "string" || !VALID_REPORT_TYPES.has(reportType)) {
    throw new UnprocessableEntityError(`Unrecognized reportType: ${reportType}`);
  }

  if (typeof description !== "string" || description.length === 0 || description.length > 256) {
    throw new BadRequestError("description must be a non-empty string of at most 256 characters");
  }

  if (typeof latitude !== "number" || latitude < -90 || latitude > 90) {
    throw new BadRequestError("latitude must be a number between -90 and 90");
  }

  if (typeof longitude !== "number" || longitude < -180 || longitude > 180) {
    throw new BadRequestError("longitude must be a number between -180 and 180");
  }

  if (typeof address !== "string" || address.length === 0 || address.length > 256) {
    throw new BadRequestError("address must be a non-empty string of at most 256 characters");
  }

  const dto: ReportSubmitDTO = {
    reportType,
    description,
    latitude,
    longitude,
    address,
  };

  if (body.zipCode !== undefined) {
    if (typeof body.zipCode !== "string") {
      throw new BadRequestError("zipCode must be a string");
    }
    dto.zipCode = body.zipCode;
  }

  if (body.attachment !== undefined) {
    if (typeof body.attachment !== "object" || body.attachment === null) {
      throw new BadRequestError("attachment must be an object with mimeType and fileSize");
    }
    const att = body.attachment as Record<string, unknown>;
    if (typeof att.mimeType !== "string" || att.mimeType.length === 0) {
      throw new BadRequestError("attachment.mimeType must be a non-empty string");
    }
    if (typeof att.fileSize !== "number" || att.fileSize <= 0 || !Number.isInteger(att.fileSize)) {
      throw new BadRequestError("attachment.fileSize must be a positive integer");
    }
    dto.attachment = {
      mimeType: att.mimeType,
      fileSize: att.fileSize,
    };
  }

  return dto;
}
