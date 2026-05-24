// DTOs for "List Reports" use case
// See: docs/use_cases/list_reports_use_case.md

import { z } from "zod";
import { BadRequestError } from "../errors";
import { REPORT_TYPES } from "./report-type.dto";
import type { ReportDTO } from "./report-submit.dto";

// ---------------------------------------------------------------------------
// Schemas
// ---------------------------------------------------------------------------

export const reportListSchema = z.object({
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(50, "limit must be at most 50").default(20),
  reportType: z
    .string()
    .optional()
    .transform((val) => val?.split(",").filter(Boolean) ?? []),
  sort: z.enum(["createdAt", "expiresAt"]).default("createdAt"),
  order: z.enum(["asc", "desc"]).default("desc"),
});

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type ReportListParams = z.infer<typeof reportListSchema>;

export type VoteSummaryDTO = {
  confirms: number;
  resolves: number;
  userVoted: string | null;
};

export type ReportWithVotesDTO = ReportDTO & {
  voteSummary: VoteSummaryDTO;
};

export type ReportListResponse = {
  reports: ReportWithVotesDTO[];
  nextCursor: string | null;
};

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------

export function validateReportListParams(input: unknown): ReportListParams {
  const result = reportListSchema.safeParse(input);
  if (!result.success) {
    const message = result.error.issues.map((i) => i.message).join("; ");
    throw new BadRequestError(message);
  }

  const params = result.data;

  // Validate reportType filter values
  if (params.reportType.length > 0) {
    for (const rt of params.reportType) {
      if (!(REPORT_TYPES as readonly string[]).includes(rt)) {
        throw new BadRequestError(`Unrecognized reportType filter: ${rt}`);
      }
    }
  }

  return params;
}
