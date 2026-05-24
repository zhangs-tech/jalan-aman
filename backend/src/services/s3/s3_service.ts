import { S3Client, PutObjectCommand, GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export class S3Service {
  private readonly client: S3Client;
  private readonly bucket: string;

  constructor() {
    this.bucket = process.env.S3_BUCKET || "my-bucket";
    this.client = new S3Client({
      endpoint: process.env.S3_ENDPOINT || "http://localhost:8333",
      region: process.env.S3_REGION || "us-east-1",
      credentials: {
        accessKeyId: process.env.S3_ACCESS_KEY_ID || "admin",
        secretAccessKey: process.env.S3_SECRET_ACCESS_KEY || "secret",
      },
      forcePathStyle: true,
    });
  }

  async generatePresignedUploadUrl(
    s3Key: string,
    mimeType: string,
    expiresInSeconds: number = 300
  ): Promise<string> {
    const command = new PutObjectCommand({
      Bucket: this.bucket,
      Key: s3Key,
      ContentType: mimeType,
    });

    return await getSignedUrl(this.client, command, {
      expiresIn: expiresInSeconds,
    });
  }

  async generatePresignedDownloadUrl(
    s3Key: string,
    expiresInSeconds: number = 3600
  ): Promise<string> {
    const command = new GetObjectCommand({
      Bucket: this.bucket,
      Key: s3Key,
    });

    return await getSignedUrl(this.client, command, {
      expiresIn: expiresInSeconds,
    });
  }
}
