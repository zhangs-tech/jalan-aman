// DTOs for "Submit Report" use case
// See: docs/use_cases/submit_report_use_case.md

import { z } from "zod";
import { BadRequestError } from "../errors";

// ---------------------------------------------------------------------------
// Schemas
// ---------------------------------------------------------------------------

const attachmentMetaSchema = z.object({
  mimeType: z.string().min(1, "attachment.mimeType must be a non-empty string"),
  fileSize: z.number().int().positive("attachment.fileSize must be a positive integer"),
});

export const reportSubmitSchema = z.object({
  reportType: z.enum([
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
  ], { message: "Unrecognized reportType" }),
  description: z.string().min(1).max(256, "description must be at most 256 characters"),
  latitude: z.number().min(-90).max(90, "latitude must be between -90 and 90"),
  longitude: z.number().min(-180).max(180, "longitude must be between -180 and 180"),
  address: z.string().min(1).max(256, "address must be at most 256 characters"),
  zipCode: z.string().optional(),
  attachment: attachmentMetaSchema.optional(),
});

// ---------------------------------------------------------------------------
// Derived types
// ---------------------------------------------------------------------------

export type AttachmentMetaDTO = z.infer<typeof attachmentMetaSchema>;
export type ReportSubmitDTO = z.infer<typeof reportSubmitSchema>;

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

export const VALID_REPORT_TYPES = [
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
] as const;

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
  const result = reportSubmitSchema.safeParse(input);
  if (!result.success) {
    const message = result.error.issues.map((i) => i.message).join("; ");
    throw new BadRequestError(message);
  }
  return result.data;
}
