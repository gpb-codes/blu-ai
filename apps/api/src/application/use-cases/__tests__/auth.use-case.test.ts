// Pruebas unitarias de AuthUseCase con repositorios falsos en memoria.
// El use case no depende de NestJS ni Prisma — se prueba en aislamiento puro.

import { describe, expect, it } from "vitest";
import { AuthUseCase } from "../auth.use-case.js";
import type { UserEntity } from "../../../domain/entities/user.entity.js";
import type { UserRepository } from "../../../domain/repositories/repositories.js";
import type { RefreshTokenRepository, StoredRefreshToken } from "../../../domain/repositories/refresh-token.repository.js";
import type { PasswordHasher, TokenPair, TokenService } from "../../../domain/services/auth-ports.js";

function makeUser(overrides: Partial<UserEntity> & { id: string }): UserEntity {
  return {
    email: "a@b.com",
    phone: null,
    displayName: "Andrea",
    timezone: "America/Mexico_City",
    plan: "FREE",
    role: "user",
    tosAcceptedAt: null,
    passwordHash: null,
    ...overrides,
  };
}

class InMemoryUserRepository implements UserRepository {
  users: UserEntity[] = [];
  findByEmail(email: string) {
    return Promise.resolve(this.users.find((u) => u.email === email) ?? null);
  }
  findById(id: string) {
    return Promise.resolve(this.users.find((u) => u.id === id) ?? null);
  }
  findByPhone() {
    return Promise.resolve(null);
  }
  create(data: { email?: string; phone?: string; displayName: string; passwordHash?: string }) {
    const u = makeUser({ id: `u${this.users.length + 1}`, ...data } as Partial<UserEntity>);
    this.users.push(u);
    return Promise.resolve(u);
  }
}

class InMemoryRefreshRepository implements RefreshTokenRepository {
  tokens = new Map<string, StoredRefreshToken>();
  persist(t: StoredRefreshToken) {
    this.tokens.set(t.tokenHash, t);
    return Promise.resolve();
  }
  revoke(tokenHash: string) {
    this.tokens.delete(tokenHash);
    return Promise.resolve();
  }
  async findValid(tokenHash: string) {
    const t = this.tokens.get(tokenHash);
    return t && t.expiresAt > new Date() ? t.userId : null;
  }
  persistCount = 0;
}

class FakeHasher implements PasswordHasher {
  async hash(plain: string) {
    return `argon:${plain}`;
  }
  async verify(hash: string, plain: string) {
    return hash === `argon:${plain}`;
  }
}

class FakeTokenService implements TokenService {
  private seq = 0;
  async signAccessToken(userId: string) {
    return `access.${userId}`;
  }
  async generateRefreshToken(userId: string): Promise<TokenPair> {
    this.seq += 1;
    const token = `rt.${userId}.${this.seq}`;
    return {
      accessToken: await this.signAccessToken(userId),
      refreshToken: token,
      refreshTokenHash: `h:${token}`,
      refreshExpiresAt: new Date(Date.now() + 30 * 24 * 3600_000),
    };
  }
  async verifyAccessToken(token: string) {
    return token.startsWith("access.") ? token.slice("access.".length) : null;
  }
  hashRefreshToken(token: string) {
    return `h:${token}`;
  }
}

function setup() {
  const users = new InMemoryUserRepository();
  const tokens = new InMemoryRefreshRepository();
  const uc = new AuthUseCase(users, tokens, new FakeHasher(), new FakeTokenService());
  return { users, tokens, uc };
}

describe("AuthUseCase.register", () => {
  it("crea el usuario con password hasheado y emite el par de tokens", async () => {
    const { users, tokens, uc } = setup();
    const res = await uc.register({ email: " USer@Blu.AI ", password: "secreto123", displayName: "User Blu" });
    expect(res.user.email).toBe("user@blu.ai");
    expect(res.user.plan).toBe("FREE");
    expect(res.accessToken).toContain("access.");
    expect(tokens.tokens.size).toBe(1);
    expect(users.users[0]?.passwordHash).toBe("argon:secreto123");
  });

  it("rechaza emails duplicados (insensible a mayúsculas)", async () => {
    const { uc } = setup();
    await uc.register({ email: "a@b.com", password: "secreto123", displayName: "Uno" });
    await expect(uc.register({ email: "A@B.COM", password: "secreto123", displayName: "Dos" })).rejects.toThrow("EMAIL_TAKEN");
  });
});

describe("AuthUseCase.login", () => {
  it("loguea con credenciales correctas", async () => {
    const { uc } = setup();
    await uc.register({ email: "a@b.com", password: "secreto123", displayName: "Andrea" });
    const res = await uc.login({ email: "a@b.com", password: "secreto123" });
    expect(res.user.displayName).toBe("Andrea");
    expect(res.accessToken).toBeTruthy();
  });

  it("rechaza contraseña incorrecta", async () => {
    const { uc } = setup();
    await uc.register({ email: "a@b.com", password: "secreto123", displayName: "Andrea" });
    await expect(uc.login({ email: "a@b.com", password: "otra-cosa" })).rejects.toThrow("INVALID_CREDENTIALS");
  });

  it("rechaza cuentas sin hash (p.ej. solo email-otp o teléfono)", async () => {
    const { users, uc } = setup();
    users.users.push(makeUser({ id: "x1", email: "otro@b.com", passwordHash: null }));
    await expect(uc.login({ email: "otro@b.com", password: "secreto123" })).rejects.toThrow("INVALID_CREDENTIALS");
  });
});

describe("AuthUseCase.refresh (rotación)", () => {
  it("rota: emite par nuevo y revoca el viejo", async () => {
    const { tokens, uc } = setup();
    const first = await uc.register({ email: "a@b.com", password: "secreto123", displayName: "Andrea" });
    const second = await uc.refresh({ refreshToken: first.refreshToken });
    expect(second.refreshToken).not.toBe(first.refreshToken);
    await expect(tokens.findValid(first.refreshTokenHash)).resolves.toBeNull();
    // el antiguo ya no sirve
    await expect(uc.refresh({ refreshToken: first.refreshToken })).rejects.toThrow("INVALID_REFRESH_TOKEN");
  });

  it("rechaza refresh desconocido o expirado", async () => {
    const { tokens, uc } = setup();
    await uc.register({ email: "a@b.com", password: "secreto123", displayName: "Andrea" });
    await expect(uc.refresh({ refreshToken: "rt-inexistente" })).rejects.toThrow("INVALID_REFRESH_TOKEN");
    tokens.persist({
      userId: "u1",
      tokenHash: "h:rt-expirado",
      expiresAt: new Date(Date.now() - 1000),
    });
    await expect(uc.refresh({ refreshToken: "rt-expirado" })).rejects.toThrow("INVALID_REFRESH_TOKEN");
  });
});

describe("AuthUseCase.logout", () => {
  it("revoca el refresh token", async () => {
    const { tokens, uc } = setup();
    const res = await uc.register({ email: "a@b.com", password: "secreto123", displayName: "Andrea" });
    await uc.logout({ refreshToken: res.refreshToken });
    await expect(tokens.findValid(res.refreshTokenHash)).resolves.toBeNull();
  });
});