package usecases

import (
	"context"
	"fmt"

	"github.com/blu-ia/api/internal/domain/repositories"
	"github.com/blu-ia/api/internal/memory"
	"github.com/blu-ia/api/internal/shared"
)

var (
	ErrNoteNotFound = fmt.Errorf("NOTE_NOT_FOUND")
)

type VaultUseCase struct {
	vault    repositories.VaultRepository
	projects repositories.ProjectRepository
}

func NewVaultUseCase(vault repositories.VaultRepository, projects repositories.ProjectRepository) *VaultUseCase {
	return &VaultUseCase{vault: vault, projects: projects}
}

func (uc *VaultUseCase) Notes(ctx context.Context, userID, projectID string) ([]shared.NoteSummary, error) {
	if err := uc.assertMember(ctx, projectID, userID); err != nil {
		return nil, err
	}
	notes, err := uc.vault.FindByProject(ctx, projectID)
	if err != nil {
		return nil, err
	}
	links, err := uc.vault.Links(ctx, projectID)
	if err != nil {
		return nil, err
	}
	backlinkCount := make(map[string]int)
	for _, l := range links {
		backlinkCount[l.TargetNoteID]++
	}
	out := make([]shared.NoteSummary, 0, len(notes))
	for _, n := range notes {
		out = append(out, shared.NoteSummary{
			ID:            n.ID,
			Title:         n.Title,
			Tags:          n.Tags,
			UpdatedAt:     n.UpdatedAt.Format("2006-01-02T15:04:05.000Z"),
			UpdatedBy:     n.UpdatedBy,
			BacklinkCount: backlinkCount[n.ID],
		})
	}
	return out, nil
}

func (uc *VaultUseCase) Search(ctx context.Context, userID, projectID, query string, limit int) ([]shared.NoteSummary, error) {
	if err := uc.assertMember(ctx, projectID, userID); err != nil {
		return nil, err
	}
	if limit <= 0 {
		limit = 10
	}
	notes, err := uc.vault.Search(ctx, projectID, query, limit)
	if err != nil {
		return nil, err
	}
	out := make([]shared.NoteSummary, 0, len(notes))
	for _, n := range notes {
		out = append(out, shared.NoteSummary{
			ID:            n.ID,
			Title:         n.Title,
			Tags:          n.Tags,
			UpdatedAt:     n.UpdatedAt.Format("2006-01-02T15:04:05.000Z"),
			UpdatedBy:     n.UpdatedBy,
			BacklinkCount: 0,
		})
	}
	return out, nil
}

func (uc *VaultUseCase) Get(ctx context.Context, userID, noteID string) (*memory.Note, error) {
	n, err := uc.vault.FindByID(ctx, noteID)
	if err != nil {
		return nil, err
	}
	if n == nil {
		return nil, ErrNoteNotFound
	}
	if err := uc.assertMember(ctx, n.ProjectID, userID); err != nil {
		return nil, err
	}
	return n, nil
}

func (uc *VaultUseCase) Create(ctx context.Context, userID string, projectID, title, bodyMd string, tags []string) (*memory.Note, error) {
	if err := uc.assertMember(ctx, projectID, userID); err != nil {
		return nil, err
	}
	return uc.vault.Create(ctx, memory.Note{
		ProjectID: projectID,
		Title:     title,
		BodyMd:    bodyMd,
		Tags:      tags,
		Source:    memory.SourceManual,
		CreatedBy: userID,
		UpdatedBy: userID,
	})
}

func (uc *VaultUseCase) Update(ctx context.Context, userID, noteID string, title, bodyMd *string, tags []string, hasTags bool) (*memory.Note, error) {
	n, err := uc.Get(ctx, userID, noteID)
	if err != nil {
		return nil, err
	}
	if err := uc.assertEditor(ctx, n.ProjectID, userID); err != nil {
		return nil, err
	}
	return uc.vault.Update(ctx, noteID, repositories.UpdateNoteData{
		Title:     title,
		BodyMd:    bodyMd,
		Tags:      tags,
		HasTags:   hasTags,
		UpdatedBy: &userID,
	})
}

func (uc *VaultUseCase) Remove(ctx context.Context, userID, noteID string) error {
	n, err := uc.Get(ctx, userID, noteID)
	if err != nil {
		return err
	}
	if err := uc.assertEditor(ctx, n.ProjectID, userID); err != nil {
		return err
	}
	return uc.vault.SoftDelete(ctx, noteID)
}

func (uc *VaultUseCase) assertMember(ctx context.Context, projectID, userID string) error {
	m, err := uc.projects.FindMembership(ctx, projectID, userID)
	if err != nil {
		return err
	}
	if m == nil {
		return ErrForbidden
	}
	return nil
}

func (uc *VaultUseCase) assertEditor(ctx context.Context, projectID, userID string) error {
	m, err := uc.projects.FindMembership(ctx, projectID, userID)
	if err != nil {
		return err
	}
	if m == nil || m.Role == shared.MemberViewer {
		return ErrForbidden
	}
	return nil
}
