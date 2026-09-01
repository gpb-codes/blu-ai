package repositories

import (
	"context"

	"github.com/blu-ia/api/internal/domain/entities"
)

type ChatSessionRepository interface {
	ListForUser(ctx context.Context, userID string, projectID *string) ([]entities.ChatSession, error)
	FindByID(ctx context.Context, sessionID string) (*entities.ChatSession, error)
	Create(ctx context.Context, data CreateSessionData) (*entities.ChatSession, error)
}

type CreateSessionData struct {
	UserID    string
	ProjectID *string
	AgentID   *string
	Title     *string
}
