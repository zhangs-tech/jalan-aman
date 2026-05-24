// DTOs for "List Comments" use case
// See: docs/use_cases/list_comments_use_case.md

import { z } from "zod";
import { BadRequestError } from "../../errors";
import type { CommentDTO } from "./comment.dto";

// ---------------------------------------------------------------------------
// Schema
// ---------------------------------------------------------------------------

export const commentListSchema = z.object({
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(100, "limit must be at most 100").default(20),
});

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type CommentListParams = z.infer<typeof commentListSchema>;

export type CommentListResponse = {
  comments: CommentDTO[];
  nextCursor: string | null;
};

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------

export function validateCommentListParams(input: unknown): CommentListParams {
  const result = commentListSchema.safeParse(input);
  if (!result.success) {
    const message = result.error.issues.map((i) => i.message).join("; ");
    throw new BadRequestError(message);
  }
  return result.data;
}
