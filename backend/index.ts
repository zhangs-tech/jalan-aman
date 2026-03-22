import express from "express";
import { authRouter } from "./src/routes/auth_route";
import { reportRouter } from "./src/routes/report_route";
import { commentRouter } from "./src/routes/comment_route";

const app = express();
const port = 3000;

app.use(express.json());

app.get("/", (req, res) => {
  res.send("Hello World!");
});

app.use("/auth", authRouter);
app.use("/reports", reportRouter);
app.use("/reports/:reportId/comments", commentRouter);

app.listen(port, () => {
  console.log(`Listening on port ${port}...`);
});