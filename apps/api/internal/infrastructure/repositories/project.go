package repositories

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/blu-ia/api/internal/domain/entities"
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

func (r *PGProjectRepository) ListForUser(ctx context.Context, userID string) ([]entities.Project, error) {
	rows, err := r.pool.Query(ctx, `SELECT id, name, slug, "ownerId", "createdAt", "updatedAt" FROM "Project" WHERE id IN (SELECT "projectId" FROM "ProjectMember" WHERE "userId"=$1) ORDER BY "updatedAt" DESC`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []entities.Project
	for rows.Next() {
		var p entities.Project
		if err := rows.Scan(&p.ID, &p.Name, &p.Slug, &p.OwnerID, &p.CreatedAt, &p.UpdatedAt); err != nil {
			return nil, err
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

func (r *PGProjectRepository) FindByID(ctx context.Context, projectID string) (*entities.Project, error) {
	var p entities.Project
	err := r.pool.QueryRow(ctx, `SELECT id, name, slug, "ownerId", "createdAt", "updatedAt" FROM "Project" WHERE id=$1`, projectID).Scan(&p.ID, &p.Name, &p.Slug, &p.OwnerID, &p.CreatedAt, &p.UpdatedAt)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, err
	}
	return &p, nil
}

func (r *PGProjectRepository) FindBySlug(ctx context.Context, slug string) (*entities.Project, error) {
	var p entities.Project
	err := r.pool.QueryRow(ctx, `SELECT id, name, slug, "ownerId", "createdAt", "updatedAt" FROM "Project" WHERE slug=$1`, slug).Scan(&p.ID, &p.Name, &p.Slug, &p.OwnerID, &p.CreatedAt, &p.UpdatedAt)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, err
	}
	return &p, nil
}

func (r *PGProjectRepository) Create(ctx context.Context, data domain.CreateProjectData) (*entities.Project, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	var p entities.Project
	err = tx.QueryRow(ctx, `INSERT INTO "Project" (id, name, slug, "ownerId", "createdAt", "updatedAt") VALUES (gen_random_uuid()::text, $1, $2, $3, now(), now()) RETURNING id, name, slug, "ownerId", "createdAt", "updatedAt"`, data.Name, data.Slug, data.OwnerID).Scan(&p.ID, &p.Name, &p.Slug, &p.OwnerID, &p.CreatedAt, &p.UpdatedAt)
	if err != nil {
		return nil, err
	}
	_, err = tx.Exec(ctx, `INSERT INTO "ProjectMember" ("projectId", "userId", role) VALUES ($1, $2, 'OWNER')`, p.ID, data.OwnerID)
	if err != nil {
		return nil, err
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return &p, nil
}

func (r *PGProjectRepository) Update(ctx context.Context, projectID string, data domain.UpdateProjectData) (*entities.Project, error) {
	var p entities.Project
	// COALESCE approach
	err := r.pool.QueryRow(ctx, `UPDATE "Project" SET name=COALESCE($2, name), slug=COALESCE($3, slug), "updatedAt"=now() WHERE id=$1 RETURNING id, name, slug, "ownerId", "createdAt", "updatedAt"`, projectID, data.Name, data.Slug).Scan(&p.ID, &p.Name, &p.Slug, &p.OwnerID, &p.CreatedAt, &p.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return &p, nil
}

func (r *PGProjectRepository) Remove(ctx context.Context, projectID string) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM "Project" WHERE id=$1`, projectID)
	return err
}

func (r *PGProjectRepository) ListMembers(ctx context.Context, projectID string) ([]domain.ProjectMemberEntity, error) {
	rows, err := r.pool.Query(ctx, `SELECT pm.role::text, u.id, u."displayName", u.email, pm."createdAt" FROM "ProjectMember" pm JOIN "User" u ON u.id=pm."userId" WHERE pm."projectId"=$1 ORDER BY pm."createdAt" ASC`, projectID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.ProjectMemberEntity
	for rows.Next() {
		var m domain.ProjectMemberEntity
		var role string
		var createdAt interface{}
		if err := rows.Scan(&role, &m.User.ID, &m.User.DisplayName, &m.User.Email, &createdAt); err != nil {
			return nil, err
		}
		m.Role = shared.MemberRole(role)
		m.CreatedAt = createdAt
		out = append(out, m)
	}
	return out, rows.Err()
}

func (r *PGProjectRepository) AddMember(ctx context.Context, projectID, userID string, role shared.MemberRole) error {
	_, err := r.pool.Exec(ctx, `INSERT INTO "ProjectMember" ("projectId", "userId", role) VALUES ($1, $2, $3::"MemberRole")`, projectID, userID, string(role))
	return err
}

func (r *PGProjectRepository) UpdateMemberRole(ctx context.Context, projectID, userID string, role shared.MemberRole) error {
	_, err := r.pool.Exec(ctx, `UPDATE "ProjectMember" SET role=$3::"MemberRole" WHERE "projectId"=$1 AND "userId"=$2`, projectID, userID, string(role))
	return err
}

func (r *PGProjectRepository) RemoveMember(ctx context.Context, projectID, userID string) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM "ProjectMember" WHERE "projectId"=$1 AND "userId"=$2`, projectID, userID)
	return err
}
