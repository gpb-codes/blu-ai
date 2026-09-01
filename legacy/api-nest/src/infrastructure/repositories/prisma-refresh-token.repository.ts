// Capa INFRASTRUCTURE: persistencia de refresh tokens en Prisma.

import { Injectable } from "@nestjs/common";
import type { RefreshTokenRepository, StoredRefreshToken } from "../../domain/repositories/refresh-token.repository.js";
import { PrismaService } from "../database/prisma.service.js";

@Injectable()
export class PrismaRefreshTokenRepository implements RefreshTokenRepository {
  constructor(private readonly prisma: PrismaService) {}

  async persist(token: StoredRefreshToken): Promise<void> {
    await this.prisma.refreshToken.create({
      data: {
        userId: token.userId,
        tokenHash: token.tokenHash,
        expiresAt: token.expiresAt,
      },
    });
  }

  async revoke(tokenHash: string): Promise<void> {
    await this.prisma.refreshToken.deleteMany({ where: { tokenHash } });
  }

  async findValid(tokenHash: string): Promise<string | null> {
    const t = await this.prisma.refreshToken.findUnique({ where: { tokenHash } });
    if (!t) return null;
    if (t.expiresAt < new Date()) {
      await this.revoke(tokenHash);
      return null;
    }
    return t.userId;
  }
}