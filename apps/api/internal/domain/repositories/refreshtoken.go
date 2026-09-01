package repositories

import (
	"context"
	"time"
)

type StoredRefreshToken struct {
	UserID    string    `json:"userId"`
	TokenHash string    `json:"tokenHash"`
	ExpiresAt time.Time `json:"expiresAt"`
}

type RefreshTokenRepository interface {
	Persist(ctx context.Context, token StoredRefreshToken) error
	Revoke(ctx context.Context, tokenHash string) error
	FindValid(ctx context.Context, tokenHash string) (*string, error)
}
