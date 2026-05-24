// DTOs for "Get Report Detail" use case
// See: docs/use_cases/get_report_detail_use_case.md

import type { ReportDTO } from "./report-submit.dto";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type VoteSummaryDTO = {
  confirms: number;
  resolves: number;
  userVoted: string | null;
};

export type AttachmentDetailDTO = {
  id: string;
  s3Key: string;
  mimeType: string;
  fileSize: number;
  createdAt: Date;
};

export type ReportDetailDTO = ReportDTO & {
  commentCount: number;
  voteSummary: VoteSummaryDTO;
  attachments: AttachmentDetailDTO[];
};

export type ReportDetailResponse = {
  report: ReportDetailDTO;
};

export type AttachmentDownloadResponse = {
  downloadUrl: string;
};
