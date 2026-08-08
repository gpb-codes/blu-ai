// Capa DOMAIN: repositorio de refresh tokens (rotación y revocación).

export interface StoredRefreshToken {
  userId: string;
  tokenHash: string;
  expiresAt: Date;
}

export interface RefreshTokenRepository {
  persist(token: StoredRefreshToken): Promise<void>;
  revoke(tokenHash: string): Promise<void>;
  /** Devuelve el userId si el hash existe y no expiró. */
  findValid(tokenHash: string): Promise<string | null>;
}