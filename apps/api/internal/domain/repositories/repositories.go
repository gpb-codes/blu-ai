package repositories

import (
	"context"

	"github.com/blu-ia/api/internal/domain/entities"
	"github.com/blu-ia/api/internal/shared"
)

type UserRepository interface {
	FindByID(ctx context.Context, id string) (*entities.User, error)
	FindByEmail(ctx context.Context, email string) (*entities.User, error)
	FindByPhone(ctx context.Context, phone string) (*entities.User, error)
	Create(ctx context.Context, data CreateUserData) (*entities.User, error)
}

type CreateUserData struct {
	Email        *string
	Phone        *string
	DisplayName  string
	PasswordHash *string
}

type ProjectRepository interface {
	FindMembership(ctx context.Context, projectID, userID string) (*ProjectMembership, error)
}

type ProjectMembership struct {
	Role shared.MemberRole `json:"role"`
}
