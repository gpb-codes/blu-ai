// Capa DOMAIN: contratos de auth. Implementaciones en infrastructure/ — el dominio
// no conoce argon2 ni JWT.

export interface PasswordHasher {
  hash(plain: string): Promise<string>;
  verify(hash: string, plain: string): Promise<boolean>;
}

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  refreshTokenHash: string;
  refreshExpiresAt: Date;
}

export interface TokenService {
  /** Firma un access token corto (JWT). */
  signAccessToken(userId: string): Promise<string>;
  /** Genera un refresh token opaco aleatorio (devuelve también su hash para almacenar). */
  generateRefreshToken(userId: string): Promise<TokenPair>;
  /** Verifica un access token; devuelve userId o null. */
  verifyAccessToken(token: string): Promise<string | null>;
  /** Hash del refresh token para comparación segura en DB. */
  hashRefreshToken(token: string): string;
}