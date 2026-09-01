package repositories

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/blu-ia/api/internal/domain/entities"
	"github.com/blu-ia/api/internal/domain/repositories"
)

type PGChatSessionRepository struct {
	pool *pgxpool.Pool
}

func NewPGChatSessionRepository(pool *pgxpool.Pool) *PGChatSessionRepository {
	return &PGChatSessionRepository{pool: pool}
}

func (r *PGChatSessionRepository) ListForUser(ctx context.Context, userID string, projectID *string) ([]entities.ChatSession, error) {
	var rows interface {
		Next() bool
		Scan(...any) error
		Close()
		Err() error
	}
	_ = rows
	var query string
	var args []any
	if projectID != nil && *projectID != "" {
		query = `SELECT id, "projectId", "userId", "agentId"::text, title, "createdAt", "updatedAt" FROM "ChatSession" WHERE "userId"=$1 AND "projectId"=$2 ORDER BY "updatedAt" DESC LIMIT 50`
		args = []any{userID, *projectID}
	} else {
		query = `SELECT id, "projectId", "userId", "agentId"::text, title, "createdAt", "updatedAt" FROM "ChatSession" WHERE "userId"=$1 ORDER BY "updatedAt" DESC LIMIT 100`
		args = []any{userID}
	}
	pgRows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer pgRows.Close()
	var out []entities.ChatSession
	for pgRows.Next() {
		var s entities.ChatSession
		if err := pgRows.Scan(&s.ID, &s.ProjectID, &s.UserID, &s.AgentID, &s.Title, &s.CreatedAt, &s.UpdatedAt); err != nil {
			return nil, err
		}
		out = append(out, s)
	}
	return out, pgRows.Err()
}

func (r *PGChatSessionRepository) FindByID(ctx context.Context, sessionID string) (*entities.ChatSession, error) {
	var s entities.ChatSession
	err := r.pool.QueryRow(ctx, `SELECT id, "projectId", "userId", "agentId"::text, title, "createdAt", "updatedAt" FROM "ChatSession" WHERE id=$1`, sessionID).Scan(&s.ID, &s.ProjectID, &s.UserID, &s.AgentID, &s.Title, &s.CreatedAt, &s.UpdatedAt)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, err
	}
	return &s, nil
}

func (r *PGChatSessionRepository) Create(ctx context.Context, data repositories.CreateSessionData) (*entities.ChatSession, error) {
	var s entities.ChatSession
	title := "Nuevo chat"
	if data.Title != nil && *data.Title != "" {
		title = *data.Title
	}
	err := r.pool.QueryRow(ctx,
		`INSERT INTO "ChatSession" (id, "projectId", "userId", "agentId", title, "createdAt", "updatedAt") VALUES (gen_random_uuid()::text, $1, $2, $3::"AgentId", $4, now(), now()) RETURNING id, "projectId", "userId", "agentId"::text, title, "createdAt", "updatedAt"`,
		data.ProjectID, data.UserID, data.AgentID, title,
	).Scan(&s.ID, &s.ProjectID, &s.UserID, &s.AgentID, &s.Title, &s.CreatedAt, &s.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return &s, nil
}
