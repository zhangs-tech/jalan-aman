import jwt from "jsonwebtoken";
import fs from "fs";

export default class JwtService {
  private readonly privateKey: string;
  private readonly publicKey: string;

  constructor() {
    const privateKeyPath =
      process.env.JWT_PRIVATE_KEY_PATH || "keys/private.pem";
    const publicKeyPath =
      process.env.JWT_PUBLIC_KEY_PATH || "keys/public.pem";

    this.privateKey = fs.readFileSync(privateKeyPath, "utf8");
    this.publicKey = fs.readFileSync(publicKeyPath, "utf8");
  }

  async generate(payload: {
    id: string;
    email: string;
    role: string;
  }): Promise<string> {
    return jwt.sign(payload, this.privateKey, {
      algorithm: "RS256",
      expiresIn: "1h",
    });
  }

  async verify(
    token: string,
  ): Promise<{ id: string; email: string; role: string }> {
    try {
      const payload = jwt.verify(token, this.publicKey, {
        algorithms: ["RS256"],
      });

      if (
        typeof payload === "object" &&
        "id" in payload &&
        "email" in payload &&
        "role" in payload
      ) {
        return payload as { id: string; email: string; role: string };
      }
      throw new Error("invalid token payload");
    } catch (error) {
      throw new Error("invalid or expired token.");
    }
  }
}
