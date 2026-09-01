// Capa APPLICATION: casos de uso de auth (register / login / refresh / logout).
// Solo dependen de interfaces (domain) — sin NestJS, sin Prisma, sin JWT directo.

import type { UserEntity } from "../../domain/entities/user.entity.js";
import type { PasswordHasher, TokenService, TokenPair } from "../../domain/services/auth-ports.js";
import type { RefreshTokenRepository } from "../../domain/repositories/refresh-token.repository.js";
import type { UserRepository } from "../../domain/repositories/repositories.js";

export type AuthResult = { user: UserEntity } & TokenPair;

export class AuthUseCase {
  constructor(
    private readonly users: UserRepository,
    private readonly tokens: RefreshTokenRepository,
    private readonly hasher: PasswordHasher,
    private readonly tokenService: TokenService,
  ) {}

  async register(input: { email: string; password: string; displayName: string }): Promise<AuthResult> {
    const email = input.email.toLowerCase().trim();
    const existing = await this.users.findByEmail(email);
    if (existing) throw new Error("EMAIL_TAKEN");

    const passwordHash = await this.hasher.hash(input.password);
    const user = await this.users.create({
      email,
      displayName: input.displayName.trim(),
      passwordHash,
    });

    return this.issueTokens(user);
  }

  async login(input: { email: string; password: string }): Promise<AuthResult> {
    const user = await this.users.findByEmail(input.email.toLowerCase().trim());
    if (!user?.passwordHash) throw new Error("INVALID_CREDENTIALS");

    const match = await this.hasher.verify(user.passwordHash, input.password);
    if (!match) throw new Error("INVALID_CREDENTIALS");

    return this.issueTokens(user);
  }

  async refresh(input: { refreshToken: string }): Promise<AuthResult> {
    const tokenHash = this.tokenService.hashRefreshToken(input.refreshToken);
    const userId = await this.tokens.findValid(tokenHash);
    if (!userId) throw new Error("INVALID_REFRESH_TOKEN");

    // Rotación: se revoca el viejo y se emite un par nuevo.
    await this.tokens.revoke(tokenHash);

    const user = await this.users.findById(userId);
    if (!user) throw new Error("INVALID_REFRESH_TOKEN");

    return this.issueTokens(user);
  }

  async logout(input: { refreshToken: string }): Promise<void> {
    await this.tokens.revoke(this.tokenService.hashRefreshToken(input.refreshToken));
  }

  private async issueTokens(user: UserEntity): Promise<AuthResult> {
    const pair = await this.tokenService.generateRefreshToken(user.id);
    await this.tokens.persist({
      userId: user.id,
      tokenHash: pair.refreshTokenHash,
      expiresAt: pair.refreshExpiresAt,
    });
    return { user, ...pair };
  }
}
