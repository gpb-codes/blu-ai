package repositories

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/blu-ia/api/internal/domain/repositories"
	"github.com/blu-ia/api/internal/infrastructure/auth"
	"github.com/blu-ia/api/internal/shared"
)

type PGUserAccountRepository struct {
	pool   *pgxpool.Pool
	cipher *auth.ApiKeyCipher
}

func NewPGUserAccountRepository(pool *pgxpool.Pool, cipher *auth.ApiKeyCipher) *PGUserAccountRepository {
	return &PGUserAccountRepository{pool: pool, cipher: cipher}
}

func (r *PGUserAccountRepository) UpdateProfile(ctx context.Context, userID string, data repositories.UpdateProfileData) (*repositories.UserEntityWrapper, error) {
	var id, displayName, timezone, plan, role string
	var email, phone *string
	var tosAcceptedAt *time.Time
	var passwordHash *string
	err := r.pool.QueryRow(ctx,
		`UPDATE "User" SET "displayName"=COALESCE($2, "displayName"), timezone=COALESCE($3, timezone), "updatedAt"=now() WHERE id=$1 RETURNING id, email, phone, "displayName", timezone, plan::text, role::text, "tosAcceptedAt", "passwordHash"`,
		userID, data.DisplayName, data.Timezone,
	).Scan(&id, &email, &phone, &displayName, &timezone, &plan, &role, &tosAcceptedAt, &passwordHash)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, err
	}
	return &repositories.UserEntityWrapper{ID: id, Email: email, Phone: phone, DisplayName: displayName, Timezone: timezone, Plan: shared.PlanID(plan), Role: shared.Role(role), TosAcceptedAt: tosAcceptedAt, PasswordHash: passwordHash}, nil
}

func (r *PGUserAccountRepository) HasApiKey(ctx context.Context, userID string, provider shared.ProviderID) (bool, error) {
	var id string
	err := r.pool.QueryRow(ctx, `SELECT id FROM "UserApiKey" WHERE "userId"=$1 AND provider=$2`, userID, string(provider)).Scan(&id)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return false, nil
		}
		return false, err
	}
	return true, nil
}

func (r *PGUserAccountRepository) SaveApiKey(ctx context.Context, userID string, provider shared.ProviderID, plainKey string) (*repositories.ApiKeyEntity, error) {
	var k repositories.ApiKeyEntity
	err := r.pool.QueryRow(ctx,
		`INSERT INTO "UserApiKey" (id, "userId", provider, "encryptedKey", "maskedKey", "createdAt", "updatedAt") VALUES (gen_random_uuid()::text, $1, $2, $3, $4, now(), now()) RETURNING id, provider, "maskedKey", "createdAt"`,
		userID, string(provider), r.cipher.Encrypt(plainKey), r.cipher.Mask(plainKey),
	).Scan(&k.ID, &k.Provider, &k.MaskedKey, &k.CreatedAt)
	if err != nil {
		return nil, err
	}
	return &k, nil
}

func (r *PGUserAccountRepository) RemoveApiKey(ctx context.Context, userID string, provider shared.ProviderID) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM "UserApiKey" WHERE "userId"=$1 AND provider=$2`, userID, string(provider))
	return err
}

func (r *PGUserAccountRepository) ListApiKeys(ctx context.Context, userID string) ([]repositories.ApiKeyEntity, error) {
	rows, err := r.pool.Query(ctx, `SELECT id, provider, "maskedKey", "createdAt" FROM "UserApiKey" WHERE "userId"=$1 ORDER BY "createdAt" DESC`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []repositories.ApiKeyEntity
	for rows.Next() {
		var k repositories.ApiKeyEntity
		var provider string
		if err := rows.Scan(&k.ID, &provider, &k.MaskedKey, &k.CreatedAt); err != nil {
			return nil, err
		}
		k.Provider = shared.ProviderID(provider)
		out = append(out, k)
	}
	return out, rows.Err()
}

func (r *PGUserAccountRepository) CreditBalance(ctx context.Context, userID string) (int, error) {
	var sum *int
	err := r.pool.QueryRow(ctx, `SELECT SUM(delta) FROM "CreditLedger" WHERE "userId"=$1`, userID).Scan(&sum)
	if err != nil {
		return 0, err
	}
	if sum == nil {
		return 0, nil
	}
	return *sum, nil
}

func (r *PGUserAccountRepository) RecordCredit(ctx context.Context, userID string, delta int, reason string) error {
	_, err := r.pool.Exec(ctx, `INSERT INTO "CreditLedger" (id, "userId", delta, reason, "createdAt") VALUES (gen_random_uuid()::text, $1, $2, $3, now())`, userID, delta, reason)
	return err
}

func (r *PGUserAccountRepository) HasDailyGrant(ctx context.Context, userID string, dayStart time.Time) (bool, error) {
	var id string
	err := r.pool.QueryRow(ctx, `SELECT id FROM "CreditLedger" WHERE "userId"=$1 AND "createdAt" >= $2 LIMIT 1`, userID, dayStart).Scan(&id)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return false, nil
		}
		return false, err
	}
	return true, nil
}
