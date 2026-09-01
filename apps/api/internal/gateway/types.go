package gateway

import (
	"context"

	"github.com/blu-ia/api/internal/shared"
)

type ProviderID = shared.ProviderID
type TierID = shared.TierID

type ProviderMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type ChatRequest struct {
	Provider  ProviderID
	Model     string
	Messages  []ProviderMessage
	Temperature *float64
	MaxTokens   *int
	APIKey      *string
	Ctx         context.Context
}

type ChatResult struct {
	Content  string
	Model    string
	Provider ProviderID
	Usage    struct {
		InputTokens  int `json:"inputTokens"`
		OutputTokens int `json:"outputTokens"`
	}
}

type ModelProvider interface {
	ID() ProviderID
	ListModels() []string
	Chat(req ChatRequest) (ChatResult, error)
}

type TierRoute struct {
	Tier       TierID `json:"tier"`
	Candidates []struct {
		Provider ProviderID `json:"provider"`
		Model    string      `json:"model"`
	} `json:"candidates"`
}

type TierRouteCandidate struct {
	Provider ProviderID
	Model    string
}

type TierRouteDef struct {
	Tier       TierID
	Candidates []TierRouteCandidate
}

type GatewayContext struct {
	UserID      *string
	Plan        shared.PlanID
	Tier        string
	AgentID     *string
	UserApiKeys map[ProviderID]string
}

type UsageRecord struct {
	UserID       string     `json:"userId"`
	Provider     ProviderID `json:"provider"`
	Model        string     `json:"model"`
	InputTokens  int        `json:"inputTokens"`
	OutputTokens int        `json:"outputTokens"`
	CostUsd      float64    `json:"costUsd"`
	BilledBy     string     `json:"billedBy"`
}
