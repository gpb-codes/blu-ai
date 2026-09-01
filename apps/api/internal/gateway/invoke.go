package gateway

import (
	"fmt"

	"github.com/blu-ia/api/internal/shared"
)

type ChatInvocation struct {
	UserID      string
	Plan        shared.PlanID
	Tier        string // "light"|"flash"|"ultra"|"auto"
	Text        string
	History     []ProviderMessage
	UserApiKeys map[ProviderID]string
}

type ChatInvocationResult struct {
	Content      string
	Usage        UsageRecord
	CreditsSpent int
}

func InvokeChat(router *TierRouter, inv ChatInvocation) (ChatInvocationResult, error) {
	if len(inv.Text) > MaxInputChars {
		return ChatInvocationResult{}, fmt.Errorf("mensaje demasiado largo (máx %d caracteres)", MaxInputChars)
	}
	tier := TierID(inv.Tier)
	if inv.Tier == "auto" {
		tier = ClassifyTask(inv.Text)
	}
	primary := router.Resolve(tier)
	var apiKey *string
	if primary != nil {
		if k, ok := inv.UserApiKeys[primary.Provider]; ok {
			apiKey = &k
		}
	}
	msgs := make([]ProviderMessage, 0, len(inv.History)+1)
	msgs = append(msgs, inv.History...)
	msgs = append(msgs, ProviderMessage{Role: "user", Content: inv.Text})

	result, err := router.Chat(tier, ChatRequest{
		Messages: msgs,
		APIKey:   apiKey,
	})
	if err != nil {
		return ChatInvocationResult{}, err
	}
	billedBy := "blu"
	if inv.Plan == shared.PlanBYOK {
		billedBy = "user"
	}
	return ChatInvocationResult{
		Content: result.Content,
		Usage: UsageRecord{
			UserID:       inv.UserID,
			Provider:     result.Provider,
			Model:        result.Model,
			InputTokens:  result.Usage.InputTokens,
			OutputTokens: result.Usage.OutputTokens,
			CostUsd:      CostUsd(result.Model, result.Usage.InputTokens, result.Usage.OutputTokens),
			BilledBy:     billedBy,
		},
		CreditsSpent: CreditsForModel(result.Model),
	}, nil
}
