package usecases

import (
	"context"
	"fmt"

	"github.com/blu-ia/api/internal/domain/repositories"
	"github.com/blu-ia/api/internal/gateway"
	"github.com/blu-ia/api/internal/memory"
	"github.com/blu-ia/api/internal/shared"
)

type ChatUseCase struct {
	gw       *gateway.TierRouter
	vault    repositories.VaultRepository
	projects repositories.ProjectRepository
}

func NewChatUseCase(gw *gateway.TierRouter, vault repositories.VaultRepository, projects repositories.ProjectRepository) *ChatUseCase {
	return &ChatUseCase{gw: gw, vault: vault, projects: projects}
}

type ChatRequestInput struct {
	UserID      string
	ProjectID   *string
	AgentID     *shared.AgentID
	Tier        string // "light"|"flash"|"ultra"|"auto"
	Text        string
	History     []gateway.ProviderMessage
	UserApiKeys map[gateway.ProviderID]string
}

type ChatResultOutput struct {
	Content      string   `json:"content"`
	UsedModel    string   `json:"usedModel"`
	CitedNotes   []string `json:"citedNotes"`
	CostUsd      float64  `json:"costUsd"`
	CreditsSpent int      `json:"creditsSpent"`
}

func (uc *ChatUseCase) Execute(ctx context.Context, input ChatRequestInput) (*ChatResultOutput, error) {
	if input.ProjectID != nil && *input.ProjectID != "" {
		m, err := uc.projects.FindMembership(ctx, *input.ProjectID, input.UserID)
		if err != nil {
			return nil, err
		}
		if m == nil {
			return nil, fmt.Errorf("Sin acceso a este proyecto")
		}
	}
	var citedNotes []string
	if input.ProjectID != nil && *input.ProjectID != "" {
		notes, err := uc.vault.Search(ctx, *input.ProjectID, input.Text, 8)
		if err != nil {
			return nil, err
		}
		links, err := uc.vault.Links(ctx, *input.ProjectID)
		if err != nil {
			return nil, err
		}
		mctx := memory.BuildMemoryContext(memory.ContextOptions{
			RelevantNotes: notes,
			Links:         links,
			MaxNotes:      5,
		})
		for _, n := range mctx.Notes {
			citedNotes = append(citedNotes, n.ID)
		}
		// memory text available as mctx.Text — injected via system prompt in future phase
		_ = mctx.Text
	}
	if citedNotes == nil {
		citedNotes = []string{}
	}
	result, err := gateway.InvokeChat(uc.gw, gateway.ChatInvocation{
		UserID:      input.UserID,
		Plan:        shared.PlanFree, // TODO fase 10: resolver plan real
		Tier:        input.Tier,
		Text:        input.Text,
		History:     input.History,
		UserApiKeys: input.UserApiKeys,
	})
	if err != nil {
		return nil, err
	}
	return &ChatResultOutput{
		Content:      result.Content,
		UsedModel:    result.Usage.Model,
		CitedNotes:   citedNotes,
		CostUsd:      result.Usage.CostUsd,
		CreditsSpent: result.CreditsSpent,
	}, nil
}
