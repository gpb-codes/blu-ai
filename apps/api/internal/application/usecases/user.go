package usecases

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/blu-ia/api/internal/domain/repositories"
	"github.com/blu-ia/api/internal/shared"
)

var (
	ErrUserNotFound        = fmt.Errorf("USER_NOT_FOUND")
	ErrKeyRequired         = fmt.Errorf("KEY_REQUIRED")
	ErrProviderNotSupported = fmt.Errorf("PROVIDER_NOT_SUPPORTED")
	ErrApiKeyExists        = fmt.Errorf("API_KEY_EXISTS")
)

var validProviders = map[shared.ProviderID]bool{
	shared.ProviderAnthropic:  true,
	shared.ProviderOpenAI:     true,
	shared.ProviderGemini:     true,
	shared.ProviderOpenRouter: true,
}

var creditPlans = map[shared.PlanID]repositories.CreditPlan{
	shared.PlanFree:    {Plan: shared.PlanFree, GrantsPerDay: 200, SoftCaps: map[string]int{"light": 1000, "flash": 200, "ultra": 50}},
	shared.PlanBYOK:    {Plan: shared.PlanBYOK, GrantsPerDay: 0, SoftCaps: map[string]int{}},
	shared.PlanCredits: {Plan: shared.PlanCredits, GrantsPerDay: 500, SoftCaps: map[string]int{"light": 2000, "flash": 500, "ultra": 120}},
}

type UserUseCase struct {
	users   repositories.UserRepository
	account repositories.UserAccountRepository
}

func NewUserUseCase(users repositories.UserRepository, account repositories.UserAccountRepository) *UserUseCase {
	return &UserUseCase{users: users, account: account}
}

func (uc *UserUseCase) Profile(ctx context.Context, userID string) (interface{}, error) {
	u, err := uc.users.FindByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if u == nil {
		return nil, ErrUserNotFound
	}
	return u, nil
}

func (uc *UserUseCase) UpdateProfile(ctx context.Context, userID string, displayName, timezone *string) (interface{}, error) {
	wrapper, err := uc.account.UpdateProfile(ctx, userID, repositories.UpdateProfileData{DisplayName: displayName, Timezone: timezone})
	if err != nil {
		return nil, err
	}
	if wrapper == nil {
		return nil, ErrUserNotFound
	}
	return wrapper, nil
}

func (uc *UserUseCase) ApiKeys(ctx context.Context, userID string) ([]repositories.ApiKeyEntity, error) {
	return uc.account.ListApiKeys(ctx, userID)
}

func (uc *UserUseCase) AddApiKey(ctx context.Context, userID string, provider shared.ProviderID, key string) (*repositories.ApiKeyEntity, error) {
	plain := strings.TrimSpace(key)
	if plain == "" {
		return nil, ErrKeyRequired
	}
	if !validProviders[provider] {
		return nil, ErrProviderNotSupported
	}
	exists, err := uc.account.HasApiKey(ctx, userID, provider)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, ErrApiKeyExists
	}
	return uc.account.SaveApiKey(ctx, userID, provider, plain)
}

func (uc *UserUseCase) RemoveApiKey(ctx context.Context, userID string, provider shared.ProviderID) error {
	return uc.account.RemoveApiKey(ctx, userID, provider)
}

type CreditsResult struct {
	Plan         shared.PlanID  `json:"plan"`
	GrantsPerDay int            `json:"grantsPerDay"`
	SoftCaps     map[string]int `json:"softCaps"`
	Credits      int            `json:"credits"`
	Frozen       bool           `json:"frozen"`
	ResetsAt     *string        `json:"resetsAt"`
}

func (uc *UserUseCase) Credits(ctx context.Context, userID string) (*CreditsResult, error) {
	u, err := uc.users.FindByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if u == nil {
		return nil, ErrUserNotFound
	}
	plan, ok := creditPlans[u.Plan]
	if !ok {
		plan = creditPlans[shared.PlanFree]
	}
	if plan.GrantsPerDay > 0 {
		dayStart := time.Now().UTC().Truncate(24 * time.Hour)
		granted, err := uc.account.HasDailyGrant(ctx, userID, dayStart)
		if err != nil {
			return nil, err
		}
		if !granted {
			_ = uc.account.RecordCredit(ctx, userID, plan.GrantsPerDay, "grant diario")
		}
	}
	balance, err := uc.account.CreditBalance(ctx, userID)
	if err != nil {
		return nil, err
	}
	if balance < 0 {
		balance = 0
	}
	var resetsAt *string
	if plan.GrantsPerDay > 0 {
		tomorrow := time.Now().UTC().Truncate(24 * time.Hour).Add(24 * time.Hour)
		s := tomorrow.Format(time.RFC3339)
		resetsAt = &s
	}
	return &CreditsResult{
		Plan:         plan.Plan,
		GrantsPerDay: plan.GrantsPerDay,
		SoftCaps:     plan.SoftCaps,
		Credits:      balance,
		Frozen:       plan.GrantsPerDay == 0,
		ResetsAt:     resetsAt,
	}, nil
}
