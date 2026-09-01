package adapters

import "github.com/blu-ia/api/internal/gateway"

func NewOpenAIProvider() *OpenAICompatibleProvider {
	return NewOpenAICompatible(
		gateway.ProviderID("openai"),
		[]string{"gpt-4o-mini", "gpt-5"},
		OpenAICompatibleOptions{BaseURL: "https://api.openai.com/v1", Label: "openai"},
		KeyFromEnv("OPENAI_API_KEY"),
	)
}
