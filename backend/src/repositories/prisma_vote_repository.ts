import type { PrismaClient } from "../generated/prisma/client";

const HOUR_MS = 60 * 60 * 1000;

export type VoteResult = {
  id: string;
  reportId: string;
  userId: string;
  type: string;
  createdAt: Date;
};

export default class PrismaVoteRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async hasRecentVote(
    reportId: string,
    userId: string,
    type: string
  ): Promise<boolean> {
    const since = new Date(Date.now() - 24 * HOUR_MS);
    const existing = await this.prisma.reportVote.findFirst({
      where: { reportId, userId, type, createdAt: { gte: since } },
    });
    return existing !== null;
  }

  async createVoteAndUpdateReport(
    reportId: string,
    userId: string,
    type: string,
    newExpiresAt: Date
  ): Promise<VoteResult> {
    return (await this.prisma.$transaction(async (tx) => {
      await tx.report.update({
        where: { id: reportId },
        data: { expiresAt: newExpiresAt },
      });

      const vote = await tx.reportVote.create({
        data: { reportId, userId, type },
      });

      return vote;
    })) as VoteResult;
  }
}
