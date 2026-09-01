package usecases

import (
	"context"
	"fmt"
	"strings"

	"github.com/blu-ia/api/internal/domain/entities"
	"github.com/blu-ia/api/internal/domain/repositories"
	"github.com/blu-ia/api/internal/domain/services"
)

var (
	ErrEmailTaken         = fmt.Errorf("EMAIL_TAKEN")
	ErrInvalidCredentials = fmt.Errorf("INVALID_CREDENTIALS")
	ErrInvalidRefreshToken = fmt.Errorf("INVALID_REFRESH_TOKEN")
)

type AuthUseCase struct {
	users        repositories.UserRepository
	tokens       repositories.RefreshTokenRepository
	hasher       services.PasswordHasher
	tokenService services.TokenService
}

func NewAuthUseCase(
	users repositories.UserRepository,
	tokens repositories.RefreshTokenRepository,
	hasher services.PasswordHasher,
	tokenService services.TokenService,
) *AuthUseCase {
	return &AuthUseCase{users: users, tokens: tokens, hasher: hasher, tokenService: tokenService}
}

type AuthResult struct {
	User         *entities.User `json:"user"`
	AccessToken  string         `json:"accessToken"`
	RefreshToken string         `json:"refreshToken"`
}

func (uc *AuthUseCase) Register(ctx context.Context, input RegisterInput) (*AuthResult, error) {
	email := strings.ToLower(strings.TrimSpace(input.Email))
	existing, err := uc.users.FindByEmail(ctx, email)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return nil, ErrEmailTaken
	}
	hash, err := uc.hasher.Hash(input.Password)
	if err != nil {
		return nil, err
	}
	user, err := uc.users.Create(ctx, repositories.CreateUserData{
		Email:        &email,
		DisplayName:  strings.TrimSpace(input.DisplayName),
		PasswordHash: &hash,
	})
	if err != nil {
		return nil, err
	}
	return uc.issueTokens(ctx, user)
}

func (uc *AuthUseCase) Login(ctx context.Context, input LoginInput) (*AuthResult, error) {
	user, err := uc.users.FindByEmail(ctx, strings.ToLower(strings.TrimSpace(input.Email)))
	if err != nil {
		return nil, err
	}
	if user == nil || user.PasswordHash == nil {
		return nil, ErrInvalidCredentials
	}
	ok, err := uc.hasher.Verify(*user.PasswordHash, input.Password)
	if err != nil {
		return nil, err
	}
	if !ok {
		return nil, ErrInvalidCredentials
	}
	return uc.issueTokens(ctx, user)
}

func (uc *AuthUseCase) Refresh(ctx context.Context, refreshToken string) (*AuthResult, error) {
	tokenHash := uc.tokenService.HashRefreshToken(refreshToken)
	userID, err := uc.tokens.FindValid(ctx, tokenHash)
	if err != nil {
		return nil, err
	}
	if userID == nil {
		return nil, ErrInvalidRefreshToken
	}
	if err := uc.tokens.Revoke(ctx, tokenHash); err != nil {
		return nil, err
	}
	user, err := uc.users.FindByID(ctx, *userID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, ErrInvalidRefreshToken
	}
	return uc.issueTokens(ctx, user)
}

func (uc *AuthUseCase) Logout(ctx context.Context, refreshToken string) error {
	return uc.tokens.Revoke(ctx, uc.tokenService.HashRefreshToken(refreshToken))
}

func (uc *AuthUseCase) issueTokens(ctx context.Context, user *entities.User) (*AuthResult, error) {
	pair, err := uc.tokenService.GenerateRefreshToken(user.ID)
	if err != nil {
		return nil, err
	}
	if err := uc.tokens.Persist(ctx, repositories.StoredRefreshToken{
		UserID:    user.ID,
		TokenHash: pair.RefreshTokenHash,
		ExpiresAt: pair.RefreshExpiresAt,
	}); err != nil {
		return nil, err
	}
	return &AuthResult{User: user, AccessToken: pair.AccessToken, RefreshToken: pair.RefreshToken}, nil
}

type RegisterInput struct {
	Email       string `json:"email"`
	Password    string `json:"password"`
	DisplayName string `json:"displayName"`
}

type LoginInput struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}
