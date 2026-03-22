import jwt from "jsonwebtoken";

export default class JwtService {
  private readonly jwtSecret = process.env.JWT_SECRET || 'awwefiuohwfuahwfjhksdfjhasd';

  async generate(payload: { id: string; email: string; role: string }): Promise<string> {
      const jwtToken = jwt.sign(payload, this.jwtSecret, { expiresIn: '1h' })
      return jwtToken
  }
  
  async verify(token: string): Promise<{ id: string; email: string; role: string }> {
    try {
      const payload = jwt.verify(token, this.jwtSecret);

      if (typeof payload === 'object' && 'id' in payload && 'email' in payload && 'role' in payload) {
          return payload as { id: string, email: string, role: string };
      }
      throw new Error('invalid token payload');
    } catch (error) {
      throw new Error('invalid or expired token.');
    }
  }
}