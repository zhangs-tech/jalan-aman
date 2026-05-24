// DTOs for "List Reports — Map" use case
// See: docs/use_cases/list_reports_use_case.md

import { z } from "zod";
import { BadRequestError } from "../errors";
import { REPORT_TYPES } from "./report-type.dto";

// ---------------------------------------------------------------------------
// Schemas
// ---------------------------------------------------------------------------

export const mapPinsSchema = z.object({
  swLat: z.coerce.number().min(-90).max(90),
  swLng: z.coerce.number().min(-180).max(180),
  neLat: z.coerce.number().min(-90).max(90),
  neLng: z.coerce.number().min(-180).max(180),
  reportType: z
    .string()
    .optional()
    .transform((val) => val?.split(",").filter(Boolean) ?? []),
});

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type MapPinsParams = z.infer<typeof mapPinsSchema>;

export type PinDTO = {
  id: string;
  reportType: string;
  latitude: number;
  longitude: number;
};

export type MapPinsResponse = {
  pins: PinDTO[];
};

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------

export function validateMapPinsParams(input: unknown): MapPinsParams {
  const result = mapPinsSchema.safeParse(input);
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
