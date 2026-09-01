package repositories

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	domain "github.com/blu-ia/api/internal/domain/repositories"
	"github.com/blu-ia/api/internal/memory"
)

type PGVaultRepository struct {
	pool *pgxpool.Pool
}

func NewPGVaultRepository(pool *pgxpool.Pool) *PGVaultRepository {
	return &PGVaultRepository{pool: pool}
}

func (r *PGVaultRepository) FindByProject(ctx context.Context, projectID string) ([]memory.Note, error) {
	rows, err := r.pool.Query(ctx, `SELECT id, "projectId", title, "bodyMd", tags, source::text, "createdBy", "updatedBy", "createdAt", "updatedAt", "deletedAt" FROM "Note" WHERE "projectId"=$1 AND "deletedAt" IS NULL ORDER BY "updatedAt" DESC`, projectID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var notes []memory.Note
	for rows.Next() {
		var n memory.Note
		var source string
		var deletedAt *time.Time
		if err := rows.Scan(&n.ID, &n.ProjectID, &n.Title, &n.BodyMd, &n.Tags, &source, &n.CreatedBy, &n.UpdatedBy, &n.CreatedAt, &n.UpdatedAt, &deletedAt); err != nil {
			return nil, err
		}
		n.Source = memory.NoteSource(source)
		n.DeletedAt = deletedAt
		notes = append(notes, n)
	}
	return notes, rows.Err()
}

func (r *PGVaultRepository) FindByID(ctx context.Context, noteID string) (*memory.Note, error) {
	var n memory.Note
	var source string
	var deletedAt *time.Time
	err := r.pool.QueryRow(ctx, `SELECT id, "projectId", title, "bodyMd", tags, source::text, "createdBy", "updatedBy", "createdAt", "updatedAt", "deletedAt" FROM "Note" WHERE id=$1`, noteID).
		Scan(&n.ID, &n.ProjectID, &n.Title, &n.BodyMd, &n.Tags, &source, &n.CreatedBy, &n.UpdatedBy, &n.CreatedAt, &n.UpdatedAt, &deletedAt)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, err
	}
	n.Source = memory.NoteSource(source)
	n.DeletedAt = deletedAt
	return &n, nil
}

func (r *PGVaultRepository) Search(ctx context.Context, projectID, query string, limit int) ([]memory.Note, error) {
	if limit <= 0 {
		limit = 8
	}
	// TODO fase 5: pgvector híbrido. Ahora LIKE simple.
	rows, err := r.pool.Query(ctx,
		`SELECT id, "projectId", title, "bodyMd", tags, source::text, "createdBy", "updatedBy", "createdAt", "updatedAt", "deletedAt"
		 FROM "Note" WHERE "projectId"=$1 AND "deletedAt" IS NULL AND (title ILIKE '%' || $2 || '%' OR "bodyMd" ILIKE '%' || $2 || '%') LIMIT $3`,
		projectID, query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var notes []memory.Note
	for rows.Next() {
		var n memory.Note
		var source string
		var deletedAt *time.Time
		if err := rows.Scan(&n.ID, &n.ProjectID, &n.Title, &n.BodyMd, &n.Tags, &source, &n.CreatedBy, &n.UpdatedBy, &n.CreatedAt, &n.UpdatedAt, &deletedAt); err != nil {
			return nil, err
		}
		n.Source = memory.NoteSource(source)
		n.DeletedAt = deletedAt
		notes = append(notes, n)
	}
	return notes, rows.Err()
}

func (r *PGVaultRepository) Create(ctx context.Context, note memory.Note) (*memory.Note, error) {
	var n memory.Note
	var source string
	var deletedAt *time.Time
	err := r.pool.QueryRow(ctx,
		`INSERT INTO "Note" (id, "projectId", title, "bodyMd", tags, source, "createdBy", "updatedBy") VALUES (gen_random_uuid()::text, $1,$2,$3,$4,$5::"NoteSource",$6,$7) RETURNING id, "projectId", title, "bodyMd", tags, source::text, "createdBy", "updatedBy", "createdAt", "updatedAt", "deletedAt"`,
		note.ProjectID, note.Title, note.BodyMd, note.Tags, string(note.Source), note.CreatedBy, note.UpdatedBy,
	).Scan(&n.ID, &n.ProjectID, &n.Title, &n.BodyMd, &n.Tags, &source, &n.CreatedBy, &n.UpdatedBy, &n.CreatedAt, &n.UpdatedAt, &deletedAt)
	if err != nil {
		return nil, err
	}
	n.Source = memory.NoteSource(source)
	n.DeletedAt = deletedAt
	return &n, nil
}

func (r *PGVaultRepository) Update(ctx context.Context, noteID string, data domain.UpdateNoteData) (*memory.Note, error) {
	var n memory.Note
	var source string
	var deletedAt *time.Time
	var tagsParam any
	if data.HasTags {
		tagsParam = data.Tags
	}
	err := r.pool.QueryRow(ctx,
		`UPDATE "Note" SET title=COALESCE($2, title), "bodyMd"=COALESCE($3, "bodyMd"), tags=COALESCE($4, tags), "updatedBy"=COALESCE($5, "updatedBy"), "updatedAt"=now() WHERE id=$1 RETURNING id, "projectId", title, "bodyMd", tags, source::text, "createdBy", "updatedBy", "createdAt", "updatedAt", "deletedAt"`,
		noteID, data.Title, data.BodyMd, tagsParam, data.UpdatedBy,
	).Scan(&n.ID, &n.ProjectID, &n.Title, &n.BodyMd, &n.Tags, &source, &n.CreatedBy, &n.UpdatedBy, &n.CreatedAt, &n.UpdatedAt, &deletedAt)
	if err != nil {
		return nil, err
	}
	n.Source = memory.NoteSource(source)
	n.DeletedAt = deletedAt
	return &n, nil
}

func (r *PGVaultRepository) SoftDelete(ctx context.Context, noteID string) error {
	_, err := r.pool.Exec(ctx, `UPDATE "Note" SET "deletedAt"=now() WHERE id=$1`, noteID)
	return err
}

func (r *PGVaultRepository) Links(ctx context.Context, projectID string) ([]memory.NoteLink, error) {
	rows, err := r.pool.Query(ctx, `SELECT "sourceNoteId", "targetNoteId", label FROM "NoteLink" WHERE "projectId"=$1`, projectID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var links []memory.NoteLink
	for rows.Next() {
		var l memory.NoteLink
		if err := rows.Scan(&l.SourceNoteID, &l.TargetNoteID, &l.Label); err != nil {
			return nil, err
		}
		links = append(links, l)
	}
	return links, rows.Err()
}
