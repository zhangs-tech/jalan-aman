// DTOs for "Add Comment" use case
// See: docs/use_cases/add_comment_use_case.md

import { z } from "zod";
import { BadRequestError } from "../../errors";
import type { CommentDTO } from "./comment.dto";
import type { ReportDTO } from "../report-submit.dto";

// ---------------------------------------------------------------------------
// Schema
// ---------------------------------------------------------------------------

export const commentSubmitSchema = z.object({
  details: z.string().min(1).max(1024, "details must be between 1 and 1024 characters"),
});

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type CommentSubmitDTO = z.infer<typeof commentSubmitSchema>;

export type CommentSubmitResponse = {
  comment: CommentDTO;
  report: ReportDTO;
};

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------

export function validateCommentSubmit(input: unknown): CommentSubmitDTO {
  const result = commentSubmitSchema.safeParse(input);
  if (!result.success) {
    const message = result.error.issues.map((i) => i.message).join("; ");
    throw new BadRequestError(message);
  }
  return result.data;
}
