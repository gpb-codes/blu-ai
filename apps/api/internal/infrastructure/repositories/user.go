package repositories

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/blu-ia/api/internal/domain/entities"
	domain "github.com/blu-ia/api/internal/domain/repositories"
	"github.com/blu-ia/api/internal/shared"
)

type PGUserRepository struct {
	pool *pgxpool.Pool
}

func NewPGUserRepository(pool *pgxpool.Pool) *PGUserRepository {
	return &PGUserRepository{pool: pool}
}

func (r *PGUserRepository) FindByID(ctx context.Context, id string) (*entities.User, error) {
	row := r.pool.QueryRow(ctx, `SELECT id, email, phone, "displayName", timezone, plan, role, "tosAcceptedAt", "passwordHash" FROM "User" WHERE id=$1`, id)
	return scanUser(row)
}

func (r *PGUserRepository) FindByEmail(ctx context.Context, email string) (*entities.User, error) {
	row := r.pool.QueryRow(ctx, `SELECT id, email, phone, "displayName", timezone, plan, role, "tosAcceptedAt", "passwordHash" FROM "User" WHERE email=$1`, email)
	u, err := scanUser(row)
	if err != nil && err.Error() == "no rows" {
		return nil, nil
	}
	return u, err
}

func (r *PGUserRepository) FindByPhone(ctx context.Context, phone string) (*entities.User, error) {
	row := r.pool.QueryRow(ctx, `SELECT id, email, phone, "displayName", timezone, plan, role, "tosAcceptedAt", "passwordHash" FROM "User" WHERE phone=$1`, phone)
	return scanUser(row)
}

func (r *PGUserRepository) Create(ctx context.Context, data domain.CreateUserData) (*entities.User, error) {
	var id string
	var email, phone, displayName, timezone, plan, role string
	var tosAcceptedAt *time.Time
	var passwordHash *string
	displayName = data.DisplayName
	timezone = "America/Mexico_City"
	plan = string(shared.PlanFree)
	role = string(shared.RoleUser)
	err := r.pool.QueryRow(ctx,
		`INSERT INTO "User" (id, email, phone, "displayName", timezone, plan, role, "passwordHash") VALUES (gen_random_uuid()::text, $1, $2, $3, $4, $5::"Plan", $6::"Role", $7) RETURNING id, email, phone, "displayName", timezone, plan::text, role::text, "tosAcceptedAt", "passwordHash"`,
		data.Email, data.Phone, displayName, timezone, plan, role, data.PasswordHash,
	).Scan(&id, &email, &phone, &displayName, &timezone, &plan, &role, &tosAcceptedAt, &passwordHash)
	if err != nil {
		return nil, err
	}
	return mapRowToUser(id, nullableStr(email), nullableStr(phone), displayName, timezone, plan, role, tosAcceptedAt, passwordHash), nil
}

func nullableStr(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}

type scannable interface {
	Scan(dest ...any) error
}

func scanUser(row scannable) (*entities.User, error) {
	var id, displayName, timezone, plan, role string
	var email, phone *string
	var tosAcceptedAt *time.Time
	var passwordHash *string
	if err := row.Scan(&id, &email, &phone, &displayName, &timezone, &plan, &role, &tosAcceptedAt, &passwordHash); err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, err
	}
	return &entities.User{
		ID:            id,
		Email:         email,
		Phone:         phone,
		DisplayName:   displayName,
		Timezone:      timezone,
		Plan:          shared.PlanID(plan),
		Role:          shared.Role(role),
		TosAcceptedAt: tosAcceptedAt,
		PasswordHash:  passwordHash,
	}, nil
}

func mapRowToUser(id string, email, phone *string, displayName, timezone, plan, role string, tosAcceptedAt *time.Time, passwordHash *string) *entities.User {
	return &entities.User{
		ID:            id,
		Email:         email,
		Phone:         phone,
		DisplayName:   displayName,
		Timezone:      timezone,
		Plan:          shared.PlanID(plan),
		Role:          shared.Role(role),
		TosAcceptedAt: tosAcceptedAt,
		PasswordHash:  passwordHash,
	}
}
