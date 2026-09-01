package repositories

import (
	"context"
	"time"

	"github.com/blu-ia/api/internal/shared"
)

type ApiKeyEntity struct {
	ID        string            `json:"id"`
	Provider  shared.ProviderID `json:"provider"`
	MaskedKey string            `json:"maskedKey"`
	CreatedAt time.Time         `json:"createdAt"`
}

type UserAccountRepository interface {
	UpdateProfile(ctx context.Context, userID string, data UpdateProfileData) (*UserEntityWrapper, error)
	HasApiKey(ctx context.Context, userID string, provider shared.ProviderID) (bool, error)
	SaveApiKey(ctx context.Context, userID string, provider shared.ProviderID, plainKey string) (*ApiKeyEntity, error)
	RemoveApiKey(ctx context.Context, userID string, provider shared.ProviderID) error
	ListApiKeys(ctx context.Context, userID string) ([]ApiKeyEntity, error)
	CreditBalance(ctx context.Context, userID string) (int, error)
	RecordCredit(ctx context.Context, userID string, delta int, reason string) error
	HasDailyGrant(ctx context.Context, userID string, dayStart time.Time) (bool, error)
}

type UpdateProfileData struct {
	DisplayName *string
	Timezone    *string
}

// Wrapper para evitar import circular con entities.User
type UserEntityWrapper struct {
	ID          string
	Email       *string
	Phone       *string
	DisplayName string
	Timezone    string
	Plan        shared.PlanID
	Role        shared.Role
	TosAcceptedAt *time.Time
	PasswordHash *string
}

type CreditPlan struct {
	Plan         shared.PlanID      `json:"plan"`
	GrantsPerDay int                `json:"grantsPerDay"`
	SoftCaps     map[string]int     `json:"softCaps"`
}
