package usecases

import (
	"context"

	"github.com/blu-ia/api/internal/domain/entities"
	"github.com/blu-ia/api/internal/domain/repositories"
)

type ChatSessionsUseCase struct {
	sessions repositories.ChatSessionRepository
	projects repositories.ProjectRepository
}

func NewChatSessionsUseCase(sessions repositories.ChatSessionRepository, projects repositories.ProjectRepository) *ChatSessionsUseCase {
	return &ChatSessionsUseCase{sessions: sessions, projects: projects}
}

func (uc *ChatSessionsUseCase) List(ctx context.Context, userID string, projectID *string) ([]entities.ChatSession, error) {
	if projectID != nil && *projectID != "" {
		if err := uc.assertMember(ctx, *projectID, userID); err != nil {
			return nil, err
		}
	}
	return uc.sessions.ListForUser(ctx, userID, projectID)
}

func (uc *ChatSessionsUseCase) Create(ctx context.Context, userID string, projectID, agentID, title *string) (*entities.ChatSession, error) {
	if projectID != nil && *projectID != "" {
		if err := uc.assertMember(ctx, *projectID, userID); err != nil {
			return nil, err
		}
	}
	return uc.sessions.Create(ctx, repositories.CreateSessionData{
		UserID:    userID,
		ProjectID: projectID,
		AgentID:   agentID,
		Title:     title,
	})
}

func (uc *ChatSessionsUseCase) assertMember(ctx context.Context, projectID, userID string) error {
	m, err := uc.projects.FindMembership(ctx, projectID, userID)
	if err != nil {
		return err
	}
	if m == nil {
		return ErrForbidden
	}
	return nil
}
