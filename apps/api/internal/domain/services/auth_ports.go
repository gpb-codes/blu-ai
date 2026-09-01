package services

import "time"

type PasswordHasher interface {
	Hash(plain string) (string, error)
	Verify(hash, plain string) (bool, error)
}

type TokenPair struct {
	AccessToken      string    `json:"accessToken"`
	RefreshToken     string    `json:"refreshToken"`
	RefreshTokenHash string    `json:"refreshTokenHash"`
	RefreshExpiresAt time.Time `json:"refreshExpiresAt"`
}

type TokenService interface {
	SignAccessToken(userID string) (string, error)
	VerifyAccessToken(token string) (string, error)
	GenerateRefreshToken(userID string) (TokenPair, error)
	HashRefreshToken(token string) string
}
