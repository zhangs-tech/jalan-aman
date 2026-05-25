import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import type { Server } from "http";

let server: Server;
let baseUrl: string;

beforeAll(async () => {
  process.env.DATABASE_URL =
    process.env.TEST_DATABASE_URL ||
    "postgresql://postgres:postgres@localhost:5434/jalanaman?schema=public";
  process.env.S3_ENDPOINT = process.env.TEST_S3_ENDPOINT || "http://localhost:8334";
  process.env.S3_BUCKET = process.env.TEST_S3_BUCKET || "my-bucket";
  process.env.S3_REGION = "us-east-1";
  process.env.S3_ACCESS_KEY_ID = "admin";
  process.env.S3_SECRET_ACCESS_KEY = "secret";
  process.env.JWT_PRIVATE_KEY_PATH = "keys/private.pem";
  process.env.JWT_PUBLIC_KEY_PATH = "keys/public.pem";

  const { execSync } = await import("node:child_process");
  execSync("bun run db generate", { env: process.env, cwd: process.cwd() });
  execSync("bun run db migrate deploy", { env: process.env, cwd: process.cwd() });

  const express = (await import("express")).default;
  const { authRouter } = await import("../../src/routes/auth_route");
  const { reportRouter } = await import("../../src/routes/report_route");
  const { commentRouter } = await import("../../src/routes/comment_route");
  const { errorMiddleware } = await import("../../src/middlewares/error_middleware");

  const app = express();
  app.use(express.json());
  app.use("/auth", authRouter);
  app.use("/reports", reportRouter);
  app.use("/reports/:reportId/comments", commentRouter);
  app.use(errorMiddleware);

  await new Promise<void>((resolve) => {
    server = app.listen(0, () => {
      const addr = server.address();
      if (addr && typeof addr !== "string") {
        baseUrl = `http://localhost:${addr.port}`;
      }
      resolve();
    });
  });
}, 120_000);

afterAll(() => {
  server?.close();
});

describe("Reports", () => {
  it("register → login → create report → resolve → delete", async () => {
    // 1. Register User A
    const registerARes = await fetch(`${baseUrl}/auth/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email: "usera@test.com",
        password: "Password1",
        name: "User A",
        phone: "081234567890",
      }),
    });
    expect(registerARes.status).toBe(201);
    const userA: any = await registerARes.json();
    expect(userA.message).toBe("Registration successful");
    expect(userA.user.email).toBe("usera@test.com");

    // 2. Login User A
    const loginARes = await fetch(`${baseUrl}/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: "usera@test.com", password: "Password1" }),
    });
    expect(loginARes.status).toBe(200);
    const loginAData: any = await loginARes.json();
    expect(loginAData.message).toBe("Login successful");
    expect(loginAData.accessToken).toBeDefined();
    const tokenA: string = loginAData.accessToken;

    // 3. User A creates a report
    const createRes = await fetch(`${baseUrl}/reports`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${tokenA}`,
      },
      body: JSON.stringify({
        reportType: "pothole",
        description: "Large pothole on Jl. Sudirman",
        latitude: -6.2146,
        longitude: 106.8231,
        address: "Jl. Sudirman, Jakarta",
        zipCode: "10220",
      }),
    });
    expect(createRes.status).toBe(201);
    const createData: any = await createRes.json();
    expect(createData.report.reportType).toBe("pothole");
    expect(createData.report.address).toBe("Jl. Sudirman, Jakarta");
    const reportId: string = createData.report.id;

    // 4. Register User B
    const registerBRes = await fetch(`${baseUrl}/auth/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email: "userb@test.com",
        password: "Password2",
        name: "User B",
        phone: "081298765432",
      }),
    });
    expect(registerBRes.status).toBe(201);

    // 5. Login User B
    const loginBRes = await fetch(`${baseUrl}/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: "userb@test.com", password: "Password2" }),
    });
    expect(loginBRes.status).toBe(200);
    const loginBData: any = await loginBRes.json();
    const tokenB: string = loginBData.accessToken;

    // 6. User B resolves the report
    const resolveRes = await fetch(`${baseUrl}/reports/${reportId}/resolve`, {
      method: "POST",
      headers: { Authorization: `Bearer ${tokenB}` },
    });
    expect(resolveRes.status).toBe(200);
    const resolveData: any = await resolveRes.json();
    expect(resolveData.vote.type).toBe("resolve");
    expect(resolveData.report.id).toBe(reportId);

    // 7. User A deletes the report
    const deleteRes = await fetch(`${baseUrl}/reports/${reportId}`, {
      method: "DELETE",
      headers: { Authorization: `Bearer ${tokenA}` },
    });
    expect(deleteRes.status).toBe(200);
    const deleteData: any = await deleteRes.json();
    expect(deleteData.message).toBe("Report deleted");
  });
});
