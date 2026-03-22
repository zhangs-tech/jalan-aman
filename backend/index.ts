import express from "express";
import { authRouter } from "./src/routes/auth_route";

const app = express();
const port = 3000;

app.use(express.json());

app.get("/", (req, res) => {
  res.send("Hello World!");
});

app.use("/auth", authRouter);

app.listen(port, () => {
  console.log(`Listening on port ${port}...`);
});