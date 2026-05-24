// Shared vote DTOs used by confirm and resolve use cases
// See: docs/use_cases/confirm_report_use_case.md, resolve_report_use_case.md

import type { ReportDTO } from "./report-submit.dto";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type ReportVoteDTO = {
  id: string;
  reportId: string;
  userId: string;
  type: string;
  createdAt: Date;
};

export type VoteResponse = {
  vote: ReportVoteDTO;
  report: ReportDTO;
};
