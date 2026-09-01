package repositories

import (
	"context"
	"fmt"
	"sync"
	"time"

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

type memProjectRepo struct{
	mu sync.Mutex
	projects map[string]entities.Project
	members map[string][]domain.ProjectMemberEntity
}
func newInMemoryProjectRepo() *memProjectRepo { return &memProjectRepo{projects: make(map[string]entities.Project), members: make(map[string][]domain.ProjectMemberEntity)} }
func (r *memProjectRepo) FindMembership(_ context.Context, projectID, userID string) (*domain.ProjectMembership, error) {
	return &domain.ProjectMembership{Role: shared.MemberOwner}, nil
}
func (r *memProjectRepo) ListForUser(_ context.Context, userID string) ([]entities.Project, error) { return nil, nil }
func (r *memProjectRepo) FindByID(_ context.Context, projectID string) (*entities.Project, error) { return nil, nil }
func (r *memProjectRepo) FindBySlug(_ context.Context, slug string) (*entities.Project, error) { return nil, nil }
func (r *memProjectRepo) Create(_ context.Context, data domain.CreateProjectData) (*entities.Project, error) {
	p := entities.Project{ID: fmt.Sprintf("proj_%d", len(r.projects)+1), Name: data.Name, Slug: data.Slug, OwnerID: data.OwnerID}
	r.mu.Lock(); r.projects[p.ID]=p; r.mu.Unlock(); return &p, nil
}
func (r *memProjectRepo) Update(_ context.Context, projectID string, data domain.UpdateProjectData) (*entities.Project, error) { return &entities.Project{ID: projectID}, nil }
func (r *memProjectRepo) Remove(_ context.Context, projectID string) error { return nil }
func (r *memProjectRepo) ListMembers(_ context.Context, projectID string) ([]domain.ProjectMemberEntity, error) { return nil, nil }
func (r *memProjectRepo) AddMember(_ context.Context, projectID, userID string, role shared.MemberRole) error { return nil }
func (r *memProjectRepo) UpdateMemberRole(_ context.Context, projectID, userID string, role shared.MemberRole) error { return nil }
func (r *memProjectRepo) RemoveMember(_ context.Context, projectID, userID string) error { return nil }

type memVaultRepo struct{}
func newInMemoryVaultRepo() *memVaultRepo { return &memVaultRepo{} }
func (r *memVaultRepo) FindByProject(_ context.Context, projectID string) ([]memory.Note, error) { return nil, nil }
func (r *memVaultRepo) FindByID(_ context.Context, noteID string) (*memory.Note, error) { return nil, nil }
func (r *memVaultRepo) Search(_ context.Context, projectID, query string, limit int) ([]memory.Note, error) { return nil, nil }
func (r *memVaultRepo) Create(_ context.Context, note memory.Note) (*memory.Note, error) { return &note, nil }
func (r *memVaultRepo) Update(_ context.Context, noteID string, data domain.UpdateNoteData) (*memory.Note, error) { return nil, fmt.Errorf("no implementado en memoria") }
func (r *memVaultRepo) SoftDelete(_ context.Context, noteID string) error { return nil }
func (r *memVaultRepo) Links(_ context.Context, projectID string) ([]memory.NoteLink, error) { return nil, nil }

type memUserAccountRepo struct{}
func newInMemoryUserAccountRepo() *memUserAccountRepo { return &memUserAccountRepo{} }
func (r *memUserAccountRepo) UpdateProfile(_ context.Context, userID string, data domain.UpdateProfileData) (*domain.UserEntityWrapper, error) { return nil, nil }
func (r *memUserAccountRepo) HasApiKey(_ context.Context, userID string, provider shared.ProviderID) (bool, error) { return false, nil }
func (r *memUserAccountRepo) SaveApiKey(_ context.Context, userID string, provider shared.ProviderID, plainKey string) (*domain.ApiKeyEntity, error) { return &domain.ApiKeyEntity{ID: "k1", Provider: provider, MaskedKey: "sk-...****"}, nil }
func (r *memUserAccountRepo) RemoveApiKey(_ context.Context, userID string, provider shared.ProviderID) error { return nil }
func (r *memUserAccountRepo) ListApiKeys(_ context.Context, userID string) ([]domain.ApiKeyEntity, error) { return nil, nil }
func (r *memUserAccountRepo) CreditBalance(_ context.Context, userID string) (int, error) { return 0, nil }
func (r *memUserAccountRepo) RecordCredit(_ context.Context, userID string, delta int, reason string) error { return nil }
func (r *memUserAccountRepo) HasDailyGrant(_ context.Context, userID string, dayStart time.Time) (bool, error) { return false, nil }

type memChatSessionRepo struct{}
func newInMemoryChatSessionRepo() *memChatSessionRepo { return &memChatSessionRepo{} }
func (r *memChatSessionRepo) ListForUser(_ context.Context, userID string, projectID *string) ([]entities.ChatSession, error) { return nil, nil }
func (r *memChatSessionRepo) FindByID(_ context.Context, sessionID string) (*entities.ChatSession, error) { return nil, nil }
func (r *memChatSessionRepo) Create(_ context.Context, data domain.CreateSessionData) (*entities.ChatSession, error) { return &entities.ChatSession{ID: "sess_1", UserID: data.UserID}, nil }

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
func NewInMemoryUserAccountRepo() domain.UserAccountRepository { return newInMemoryUserAccountRepo() }
func NewInMemoryChatSessionRepo() domain.ChatSessionRepository { return newInMemoryChatSessionRepo() }
