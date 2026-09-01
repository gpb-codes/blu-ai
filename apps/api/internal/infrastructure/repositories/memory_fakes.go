package repositories

import (
	"context"
	"fmt"
	"sync"

	"github.com/blu-ia/api/internal/domain/entities"
	domain "github.com/blu-ia/api/internal/domain/repositories"
	"github.com/blu-ia/api/internal/memory"
	"github.com/blu-ia/api/internal/shared"
)

// --- in-memory fakes para modo sin DB ---

type memUserRepo struct {
	mu    sync.Mutex
	users map[string]*entities.User
	byEmail map[string]*entities.User
}

func newInMemoryUserRepo() *memUserRepo {
	return &memUserRepo{users: make(map[string]*entities.User), byEmail: make(map[string]*entities.User)}
}
func (r *memUserRepo) FindByID(_ context.Context, id string) (*entities.User, error) {
	r.mu.Lock(); defer r.mu.Unlock()
	return r.users[id], nil
}
func (r *memUserRepo) FindByEmail(_ context.Context, email string) (*entities.User, error) {
	r.mu.Lock(); defer r.mu.Unlock()
	return r.byEmail[email], nil
}
func (r *memUserRepo) FindByPhone(_ context.Context, phone string) (*entities.User, error) { return nil, nil }
func (r *memUserRepo) Create(_ context.Context, data domain.CreateUserData) (*entities.User, error) {
	r.mu.Lock(); defer r.mu.Unlock()
	id := fmt.Sprintf("user_%d", len(r.users)+1)
	u := &entities.User{ID: id, Email: data.Email, Phone: data.Phone, DisplayName: data.DisplayName, Timezone: "America/Mexico_City", Plan: shared.PlanFree, Role: shared.RoleUser, PasswordHash: data.PasswordHash}
	r.users[id] = u
	if data.Email != nil {
		r.byEmail[*data.Email] = u
	}
	return u, nil
}

type memProjectRepo struct{}
func newInMemoryProjectRepo() *memProjectRepo { return &memProjectRepo{} }
func (r *memProjectRepo) FindMembership(_ context.Context, projectID, userID string) (*domain.ProjectMembership, error) {
	return &domain.ProjectMembership{Role: shared.MemberOwner}, nil
}

type memVaultRepo struct{}
func newInMemoryVaultRepo() *memVaultRepo { return &memVaultRepo{} }
func (r *memVaultRepo) FindByProject(_ context.Context, projectID string) ([]memory.Note, error) { return nil, nil }
func (r *memVaultRepo) FindByID(_ context.Context, noteID string) (*memory.Note, error) { return nil, nil }
func (r *memVaultRepo) Search(_ context.Context, projectID, query string, limit int) ([]memory.Note, error) { return nil, nil }
func (r *memVaultRepo) Create(_ context.Context, note memory.Note) (*memory.Note, error) { return &note, nil }
func (r *memVaultRepo) Update(_ context.Context, noteID string, data domain.UpdateNoteData) (*memory.Note, error) { return nil, fmt.Errorf("no implementado en memoria") }
func (r *memVaultRepo) Links(_ context.Context, projectID string) ([]memory.NoteLink, error) { return nil, nil }

type memRefreshRepo struct {
	mu sync.Mutex
	m  map[string]domain.StoredRefreshToken
}
func newInMemoryRefreshRepo() *memRefreshRepo { return &memRefreshRepo{m: make(map[string]domain.StoredRefreshToken)} }
func (r *memRefreshRepo) Persist(_ context.Context, t domain.StoredRefreshToken) error {
	r.mu.Lock(); defer r.mu.Unlock()
	r.m[t.TokenHash] = t
	return nil
}
func (r *memRefreshRepo) Revoke(_ context.Context, h string) error {
	r.mu.Lock(); defer r.mu.Unlock()
	delete(r.m, h)
	return nil
}
func (r *memRefreshRepo) FindValid(_ context.Context, h string) (*string, error) {
	r.mu.Lock(); defer r.mu.Unlock()
	t, ok := r.m[h]
	if !ok {
		return nil, nil
	}
	return &t.UserID, nil
}

// exported constructors for main.go (same package, but accessible via unexported if main imports infraRepo)
func NewInMemoryUserRepo() domain.UserRepository { return newInMemoryUserRepo() }
func NewInMemoryProjectRepo() domain.ProjectRepository { return newInMemoryProjectRepo() }
func NewInMemoryVaultRepo() domain.VaultRepository { return newInMemoryVaultRepo() }
func NewInMemoryRefreshRepo() domain.RefreshTokenRepository { return newInMemoryRefreshRepo() }
