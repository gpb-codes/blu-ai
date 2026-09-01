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
	ListForUser(ctx context.Context, userID string) ([]entities.Project, error)
	FindByID(ctx context.Context, projectID string) (*entities.Project, error)
	FindBySlug(ctx context.Context, slug string) (*entities.Project, error)
	Create(ctx context.Context, data CreateProjectData) (*entities.Project, error)
	Update(ctx context.Context, projectID string, data UpdateProjectData) (*entities.Project, error)
	Remove(ctx context.Context, projectID string) error
	ListMembers(ctx context.Context, projectID string) ([]ProjectMemberEntity, error)
	AddMember(ctx context.Context, projectID, userID string, role shared.MemberRole) error
	UpdateMemberRole(ctx context.Context, projectID, userID string, role shared.MemberRole) error
	RemoveMember(ctx context.Context, projectID, userID string) error
}

type CreateProjectData struct {
	Name    string
	Slug    string
	OwnerID string
}

type UpdateProjectData struct {
	Name *string
	Slug *string
}

type ProjectMembership struct {
	Role shared.MemberRole `json:"role"`
}

type ProjectMemberEntity struct {
	Role      shared.MemberRole `json:"role"`
	User      struct {
		ID          string  `json:"id"`
		DisplayName string  `json:"displayName"`
		Email       *string `json:"email"`
	} `json:"user"`
	CreatedAt interface{} `json:"createdAt"`
}
