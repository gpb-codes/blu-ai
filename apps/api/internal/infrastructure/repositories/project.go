package repositories

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
	domain "github.com/blu-ia/api/internal/domain/repositories"
	"github.com/blu-ia/api/internal/shared"
)

type PGProjectRepository struct {
	pool *pgxpool.Pool
}

func NewPGProjectRepository(pool *pgxpool.Pool) *PGProjectRepository {
	return &PGProjectRepository{pool: pool}
}

func (r *PGProjectRepository) FindMembership(ctx context.Context, projectID, userID string) (*domain.ProjectMembership, error) {
	var role string
	err := r.pool.QueryRow(ctx, `SELECT role::text FROM "ProjectMember" WHERE "projectId"=$1 AND "userId"=$2`, projectID, userID).Scan(&role)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, err
	}
	return &domain.ProjectMembership{Role: shared.MemberRole(role)}, nil
}
