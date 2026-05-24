// DTOs for "Edit Report" use case
// See: docs/use_cases/edit_report_use_case.md

import { z } from "zod";
import { BadRequestError } from "../errors";
import type { ReportDTO } from "./report-submit.dto";

// ---------------------------------------------------------------------------
// Schema
// ---------------------------------------------------------------------------

export const reportEditSchema = z.object({
  description: z.string().min(1).max(256, "description must be at most 256 characters"),
  address: z.string().min(1).max(256, "address must be at most 256 characters"),
  userLat: z.number().min(-90).max(90, "userLat must be between -90 and 90"),
  userLng: z.number().min(-180).max(180, "userLng must be between -180 and 180"),
});

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type ReportEditDTO = z.infer<typeof reportEditSchema>;

export type ReportEditResponse = {
  report: ReportDTO;
};

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------

export function validateReportEdit(input: unknown): ReportEditDTO {
  const result = reportEditSchema.safeParse(input);
  if (!result.success) {
    const message = result.error.issues.map((i) => i.message).join("; ");
    throw new BadRequestError(message);
  }
  return result.data;
}
