package repositories

import (
	"context"

	"github.com/blu-ia/api/internal/memory"
)

type VaultRepository interface {
	FindByProject(ctx context.Context, projectID string) ([]memory.Note, error)
	FindByID(ctx context.Context, noteID string) (*memory.Note, error)
	Search(ctx context.Context, projectID, query string, limit int) ([]memory.Note, error)
	Create(ctx context.Context, note memory.Note) (*memory.Note, error)
	Update(ctx context.Context, noteID string, data UpdateNoteData) (*memory.Note, error)
	SoftDelete(ctx context.Context, noteID string) error
	Links(ctx context.Context, projectID string) ([]memory.NoteLink, error)
}

type UpdateNoteData struct {
	Title     *string
	BodyMd    *string
	Tags      []string
	HasTags   bool
	UpdatedBy *string
}
