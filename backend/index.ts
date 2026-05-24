import express from "express";
import { authRouter } from "./src/routes/auth_route";
import { reportRouter } from "./src/routes/report_route";
import { commentRouter } from "./src/routes/comment_route";
import { errorMiddleware } from "./src/middlewares/error_middleware";
import swaggerUi from "swagger-ui-express";
import { buildOpenApiDoc } from "./src/openapi";

export const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.get("/", (_req, res) => {
  res.send("Hello World!");
});

app.use("/auth", authRouter);
app.use("/reports", reportRouter);
app.use("/reports/:reportId/comments", commentRouter);
app.use("/docs", swaggerUi.serve, swaggerUi.setup(buildOpenApiDoc()));

app.use(errorMiddleware);

app.listen(port, () => {
  console.log(`Listening on port ${port}...`);
});