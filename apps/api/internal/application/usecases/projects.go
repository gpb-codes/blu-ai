package usecases

import (
	"context"
	"fmt"
	"regexp"
	"strings"
	"time"

	"github.com/blu-ia/api/internal/domain/entities"
	"github.com/blu-ia/api/internal/domain/repositories"
	"github.com/blu-ia/api/internal/shared"
)

var (
	ErrNameRequired    = fmt.Errorf("NAME_REQUIRED")
	ErrProjectNotFound = fmt.Errorf("PROJECT_NOT_FOUND")
	ErrAlreadyMember   = fmt.Errorf("ALREADY_MEMBER")
	ErrLastOwner       = fmt.Errorf("LAST_OWNER")
	ErrForbidden       = fmt.Errorf("FORBIDDEN_PROJECT")
)

var manageRoles = []shared.MemberRole{shared.MemberOwner, shared.MemberAdmin}

type ProjectsUseCase struct {
	projects repositories.ProjectRepository
}

func NewProjectsUseCase(projects repositories.ProjectRepository) *ProjectsUseCase {
	return &ProjectsUseCase{projects: projects}
}

type ProjectWithMeta struct {
	entities.Project
	Role        shared.MemberRole `json:"role"`
	MemberCount int               `json:"memberCount"`
}

func (uc *ProjectsUseCase) List(ctx context.Context, userID string) ([]ProjectWithMeta, error) {
	owned, err := uc.projects.ListForUser(ctx, userID)
	if err != nil {
		return nil, err
	}
	var out []ProjectWithMeta
	for _, p := range owned {
		membership, err := uc.projects.FindMembership(ctx, p.ID, userID)
		if err != nil {
			return nil, err
		}
		members, err := uc.projects.ListMembers(ctx, p.ID)
		if err != nil {
			return nil, err
		}
		role := shared.MemberViewer
		if membership != nil {
			role = membership.Role
		}
		out = append(out, ProjectWithMeta{Project: p, Role: role, MemberCount: len(members)})
	}
	if out == nil {
		out = []ProjectWithMeta{}
	}
	return out, nil
}

func (uc *ProjectsUseCase) Create(ctx context.Context, userID string, name string) (*entities.Project, error) {
	trimmed := strings.TrimSpace(name)
	if trimmed == "" {
		return nil, ErrNameRequired
	}
	slug, err := uc.uniqueSlug(ctx, slugify(trimmed))
	if err != nil {
		return nil, err
	}
	return uc.projects.Create(ctx, repositories.CreateProjectData{Name: trimmed, Slug: slug, OwnerID: userID})
}

func (uc *ProjectsUseCase) Get(ctx context.Context, userID, projectID string) (*entities.Project, error) {
	p, err := uc.projects.FindByID(ctx, projectID)
	if err != nil {
		return nil, err
	}
	if p == nil {
		return nil, ErrProjectNotFound
	}
	if err := uc.assertMember(ctx, projectID, userID); err != nil {
		return nil, err
	}
	return p, nil
}

func (uc *ProjectsUseCase) Update(ctx context.Context, userID, projectID string, name *string) (*entities.Project, error) {
	if err := uc.assertRole(ctx, projectID, userID, manageRoles); err != nil {
		return nil, err
	}
	data := repositories.UpdateProjectData{}
	if name != nil {
		trimmed := strings.TrimSpace(*name)
		if trimmed == "" {
			return nil, ErrNameRequired
		}
		slug, err := uc.uniqueSlug(ctx, slugify(trimmed))
		if err != nil {
			return nil, err
		}
		data.Name = &trimmed
		data.Slug = &slug
	}
	return uc.projects.Update(ctx, projectID, data)
}

func (uc *ProjectsUseCase) Remove(ctx context.Context, userID, projectID string) error {
	if err := uc.assertRole(ctx, projectID, userID, []shared.MemberRole{shared.MemberOwner}); err != nil {
		return err
	}
	return uc.projects.Remove(ctx, projectID)
}

func (uc *ProjectsUseCase) Members(ctx context.Context, userID, projectID string) ([]repositories.ProjectMemberEntity, error) {
	if err := uc.assertMember(ctx, projectID, userID); err != nil {
		return nil, err
	}
	return uc.projects.ListMembers(ctx, projectID)
}

func (uc *ProjectsUseCase) AddMember(ctx context.Context, userID, projectID, targetUserID string, role shared.MemberRole) error {
	if err := uc.assertRole(ctx, projectID, userID, manageRoles); err != nil {
		return err
	}
	existing, err := uc.projects.FindMembership(ctx, projectID, targetUserID)
	if err != nil {
		return err
	}
	if existing != nil {
		return ErrAlreadyMember
	}
	return uc.projects.AddMember(ctx, projectID, targetUserID, role)
}

func (uc *ProjectsUseCase) UpdateMemberRole(ctx context.Context, userID, projectID, targetUserID string, role shared.MemberRole) error {
	if err := uc.assertRole(ctx, projectID, userID, manageRoles); err != nil {
		return err
	}
	if err := uc.assertMember(ctx, projectID, targetUserID); err != nil {
		return err
	}
	return uc.projects.UpdateMemberRole(ctx, projectID, targetUserID, role)
}

func (uc *ProjectsUseCase) RemoveMember(ctx context.Context, userID, projectID, targetUserID string) error {
	if err := uc.assertRole(ctx, projectID, userID, manageRoles); err != nil {
		return err
	}
	if err := uc.assertMember(ctx, projectID, targetUserID); err != nil {
		return err
	}
	if targetUserID == userID {
		members, err := uc.projects.ListMembers(ctx, projectID)
		if err != nil {
			return err
		}
		owners := 0
		for _, m := range members {
			if m.Role == shared.MemberOwner {
				owners++
			}
		}
		if owners <= 1 {
			return ErrLastOwner
		}
	}
	return uc.projects.RemoveMember(ctx, projectID, targetUserID)
}

func (uc *ProjectsUseCase) assertMember(ctx context.Context, projectID, userID string) error {
	m, err := uc.projects.FindMembership(ctx, projectID, userID)
	if err != nil {
		return err
	}
	if m == nil {
		return ErrForbidden
	}
	return nil
}

func (uc *ProjectsUseCase) assertRole(ctx context.Context, projectID, userID string, roles []shared.MemberRole) error {
	m, err := uc.projects.FindMembership(ctx, projectID, userID)
	if err != nil {
		return err
	}
	if m == nil {
		return ErrForbidden
	}
	for _, r := range roles {
		if m.Role == r {
			return nil
		}
	}
	return ErrForbidden
}

func (uc *ProjectsUseCase) uniqueSlug(ctx context.Context, base string) (string, error) {
	slug := base
	for i := 2; i < 100; i++ {
		existing, err := uc.projects.FindBySlug(ctx, slug)
		if err != nil {
			return "", err
		}
		if existing == nil {
			return slug, nil
		}
		slug = fmt.Sprintf("%s-%d", base, i)
	}
	return fmt.Sprintf("%s-%d", base, time.Now().Unix()), nil
}

var slugRe = regexp.MustCompile(`[^a-z0-9]+`)

func slugify(name string) string {
	// NFD normalization via strings, fallback without unicode/norm
	s := strings.ToLower(name)
	// strip accents crudely: replace common
	replacer := strings.NewReplacer("á", "a", "é", "e", "í", "i", "ó", "o", "ú", "u", "ñ", "n", "ü", "u")
	s = replacer.Replace(s)
	s = slugRe.ReplaceAllString(s, "-")
	s = strings.Trim(s, "-")
	if s == "" {
		return "proyecto"
	}
	return s
}
