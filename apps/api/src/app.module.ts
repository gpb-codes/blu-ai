// Composición de la raíz: el módulo conoce todas las capas y las une.
// presentation/ → application/ → domain/ ← infrastructure/ (inyección de dependencias).

import { Module } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { JwtModule } from "@nestjs/jwt";
import { PassportModule } from "@nestjs/passport";
import { TierRouter, createProviders, type TierRoute } from "@blu-ia/ai-gateway";
import { ChatUseCase } from "./application/use-cases/chat.use-case.js";
import { AuthUseCase } from "./application/use-cases/auth.use-case.js";
import {
  PrismaProjectRepository,
  PrismaUserRepository,
  PrismaVaultRepository,
} from "./infrastructure/repositories/prisma.repositories.js";
import { PrismaRefreshTokenRepository } from "./infrastructure/repositories/prisma-refresh-token.repository.js";
import { PrismaService } from "./infrastructure/database/prisma.service.js";
import { Argon2PasswordHasher } from "./infrastructure/auth/password-argon2.service.js";
import { JwtTokenService } from "./infrastructure/auth/jwt-token.service.js";
import { JwtStrategy } from "./infrastructure/auth/jwt.strategy.js";
import { AuthController } from "./presentation/controllers/auth.controller.js";
import { ChatController } from "./presentation/controllers/chat.controller.js";
import { HealthController } from "./presentation/controllers/health.controller.js";

// Config de tiers → modelos (hot-swap sin código). Ver plan §6.
const DEFAULT_TIER_ROUTES: TierRoute[] = [
  { tier: "light", candidates: [{ provider: "gemini", model: "gemini-flash" }] },
  { tier: "flash", candidates: [{ provider: "openai", model: "gpt-4o-mini" }] },
  { tier: "ultra", candidates: [{ provider: "anthropic", model: "claude-sonnet-5" }] },
];

const tierRouterProvider = {
  provide: TierRouter,
  useFactory: () => new TierRouter(createProviders(), DEFAULT_TIER_ROUTES),
};

const authUseCaseProvider = {
  provide: AuthUseCase,
  useFactory: (
    users: PrismaUserRepository,
    tokens: PrismaRefreshTokenRepository,
    hasher: Argon2PasswordHasher,
    tokenService: JwtTokenService,
  ) => new AuthUseCase(users, tokens, hasher, tokenService),
  inject: [PrismaUserRepository, PrismaRefreshTokenRepository, Argon2PasswordHasher, JwtTokenService],
};

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, envFilePath: [".env", "../../.env"] }),
    PassportModule.register({ defaultStrategy: "jwt" }),
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.get("JWT_SECRET") ?? "dev-secret-change-me",
        signOptions: { expiresIn: "15m", algorithm: "HS256" },
      }),
    }),
  ],
  controllers: [HealthController, ChatController, AuthController],
  providers: [
    tierRouterProvider,
    PrismaService,
    PrismaUserRepository,
    PrismaProjectRepository,
    PrismaVaultRepository,
    PrismaRefreshTokenRepository,
    Argon2PasswordHasher,
    JwtTokenService,
    JwtStrategy,
    authUseCaseProvider,
    { provide: ChatUseCase, useFactory: (router, vault, projects) => new ChatUseCase(router, vault, projects), inject: [TierRouter, PrismaVaultRepository, PrismaProjectRepository] },
  ],
})
export class AppModule {}
