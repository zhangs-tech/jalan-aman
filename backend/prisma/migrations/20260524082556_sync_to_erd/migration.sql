/*
  Warnings:

  - The primary key for the `Comment` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `commentID` on the `Comment` table. All the data in the column will be lost.
  - You are about to drop the column `reportID` on the `Comment` table. All the data in the column will be lost.
  - You are about to drop the column `userID` on the `Comment` table. All the data in the column will be lost.
  - The primary key for the `Report` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `imgB64` on the `Report` table. All the data in the column will be lost.
  - You are about to drop the column `reportID` on the `Report` table. All the data in the column will be lost.
  - You are about to drop the column `reportedAt` on the `Report` table. All the data in the column will be lost.
  - You are about to drop the column `status` on the `Report` table. All the data in the column will be lost.
  - You are about to drop the `ReportHistory` table. If the table is not empty, all the data it contains will be lost.
  - The required column `id` was added to the `Comment` table with a prisma-level default value. This is not possible if the table is not empty. Please add this column as optional, then populate it before making it required.
  - Added the required column `reportId` to the `Comment` table without a default value. This is not possible if the table is not empty.
  - Added the required column `userId` to the `Comment` table without a default value. This is not possible if the table is not empty.
  - Added the required column `expiresAt` to the `Report` table without a default value. This is not possible if the table is not empty.
  - The required column `id` was added to the `Report` table with a prisma-level default value. This is not possible if the table is not empty. Please add this column as optional, then populate it before making it required.
  - Added the required column `reportType` to the `Report` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "Comment" DROP CONSTRAINT "Comment_reportID_fkey";

-- DropForeignKey
ALTER TABLE "Comment" DROP CONSTRAINT "Comment_userID_fkey";

-- DropForeignKey
ALTER TABLE "ReportHistory" DROP CONSTRAINT "ReportHistory_changedBy_fkey";

-- DropForeignKey
ALTER TABLE "ReportHistory" DROP CONSTRAINT "ReportHistory_reportID_fkey";

-- AlterTable
ALTER TABLE "Comment" DROP CONSTRAINT "Comment_pkey",
DROP COLUMN "commentID",
DROP COLUMN "reportID",
DROP COLUMN "userID",
ADD COLUMN     "id" TEXT NOT NULL,
ADD COLUMN     "reportId" TEXT NOT NULL,
ADD COLUMN     "userId" TEXT NOT NULL,
ADD CONSTRAINT "Comment_pkey" PRIMARY KEY ("id");

-- AlterTable
ALTER TABLE "Report" DROP CONSTRAINT "Report_pkey",
DROP COLUMN "imgB64",
DROP COLUMN "reportID",
DROP COLUMN "reportedAt",
DROP COLUMN "status",
ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "deletedAt" TIMESTAMP(3),
ADD COLUMN     "expiresAt" TIMESTAMP(3) NOT NULL,
ADD COLUMN     "id" TEXT NOT NULL,
ADD COLUMN     "reportType" TEXT NOT NULL,
ALTER COLUMN "zipCode" DROP NOT NULL,
ADD CONSTRAINT "Report_pkey" PRIMARY KEY ("id");

-- DropTable
DROP TABLE "ReportHistory";

-- CreateTable
CREATE TABLE "ReportVote" (
    "id" TEXT NOT NULL,
    "reportId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ReportVote_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Attachment" (
    "id" TEXT NOT NULL,
    "reportId" TEXT NOT NULL,
    "s3Key" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "fileSize" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Attachment_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "ReportVote" ADD CONSTRAINT "ReportVote_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES "Report"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReportVote" ADD CONSTRAINT "ReportVote_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comment" ADD CONSTRAINT "Comment_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES "Report"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comment" ADD CONSTRAINT "Comment_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Attachment" ADD CONSTRAINT "Attachment_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES "Report"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
