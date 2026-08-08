// Capa INFRASTRUCTURE: JWT (access) + refresh tokens opacos con rotación.
// El JWT tiene expiración corta; el refresh es un token aleatorio con hash en DB.

import { Injectable } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { ConfigService } from "@nestjs/config";
import { createHash, randomBytes } from "node:crypto";
import type { TokenPair, TokenService } from "../../domain/services/auth-ports.js";

// "30d", "12h", "45m" → ms. Fallback a días si no parsea.
function parseDuration(value: string | undefined, fallbackDays: number): number {
  if (!value) return fallbackDays * 24 * 60 * 60 * 1000;
  const match = /^\s*(\d+(?:\.\d+)?)\s*(ms|s|m|h|d)?\s*$/i.exec(value);
  if (!match) return fallbackDays * 24 * 60 * 60 * 1000;
  const n = Number(match[1]);
  const unit = (match[2] ?? "d").toLowerCase();
  const mult: Record<string, number> = { ms: 1, s: 1000, m: 60000, h: 3600000, d: 86400000 };
  return n * (mult[unit] ?? 86400000);
}

@Injectable()
export class JwtTokenService implements TokenService {
  private readonly refreshTtlMs: number;

  constructor(
    private readonly jwt: JwtService,
    config: ConfigService,
  ) {
    this.refreshTtlMs = parseDuration(config.get("JWT_REFRESH_EXPIRES_IN"), 30);
  }

  async signAccessToken(userId: string): Promise<string> {
    return this.jwt.signAsync({ sub: userId });
  }

  async verifyAccessToken(token: string): Promise<string | null> {
    try {
      const payload = await this.jwt.verifyAsync<{ sub: string }>(token);
      return payload.sub ?? null;
    } catch {
      return null;
    }
  }

  async generateRefreshToken(userId: string): Promise<TokenPair> {
    const token = randomBytes(48).toString("base64url");
    const refreshExpiresAt = new Date(Date.now() + this.refreshTtlMs);
    return {
      accessToken: await this.signAccessToken(userId),
      refreshToken: token,
      refreshTokenHash: this.hashRefreshToken(token),
      refreshExpiresAt,
    };
  }

  hashRefreshToken(token: string): string {
    return createHash("sha256").update(token).digest("hex");
  }
}