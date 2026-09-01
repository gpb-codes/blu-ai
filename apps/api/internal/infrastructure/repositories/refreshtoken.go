package repositories

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	domain "github.com/blu-ia/api/internal/domain/repositories"
)

type PGRefreshTokenRepository struct {
	pool *pgxpool.Pool
}

func NewPGRefreshTokenRepository(pool *pgxpool.Pool) *PGRefreshTokenRepository {
	return &PGRefreshTokenRepository{pool: pool}
}

func (r *PGRefreshTokenRepository) Persist(ctx context.Context, token domain.StoredRefreshToken) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO "RefreshToken" (id, "userId", "tokenHash", "expiresAt") VALUES (gen_random_uuid()::text, $1, $2, $3)`,
		token.UserID, token.TokenHash, token.ExpiresAt,
	)
	return err
}

func (r *PGRefreshTokenRepository) Revoke(ctx context.Context, tokenHash string) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM "RefreshToken" WHERE "tokenHash"=$1`, tokenHash)
	return err
}

func (r *PGRefreshTokenRepository) FindValid(ctx context.Context, tokenHash string) (*string, error) {
	var userID string
	var expiresAt time.Time
	err := r.pool.QueryRow(ctx, `SELECT "userId", "expiresAt" FROM "RefreshToken" WHERE "tokenHash"=$1`, tokenHash).Scan(&userID, &expiresAt)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, err
	}
	if time.Now().After(expiresAt) {
		return nil, nil
	}
	return &userID, nil
}
