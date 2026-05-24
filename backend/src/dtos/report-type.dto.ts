// Shared report type schema and constants
// Used by: submit, list, vote, edit, delete use cases

import { z } from "zod";

export const REPORT_TYPES = [
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

export const reportTypeSchema = z.enum(REPORT_TYPES, {
  message: "Unrecognized reportType",
});

export type ReportType = z.infer<typeof reportTypeSchema>;

export const TTL_HOURS: Record<ReportType, number> = {
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
