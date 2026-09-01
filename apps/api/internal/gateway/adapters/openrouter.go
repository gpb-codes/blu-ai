package adapters

import "github.com/blu-ia/api/internal/gateway"

func NewOpenRouterProvider() *OpenAICompatibleProvider {
	return NewOpenAICompatible(
		gateway.ProviderID("openrouter"),
		[]string{"deepseek-chat", "qwen-finetune-light", "gpt-4o-mini", "claude-sonnet-5"},
		OpenAICompatibleOptions{
			BaseURL: "https://openrouter.ai/api/v1",
			Label:   "openrouter",
			ExtraHeaders: map[string]string{
				"x-title":      "BLU IA",
				"http-referer": "https://blu-ia.com",
			},
		},
		KeyFromEnv("OPENROUTER_API_KEY"),
	)
}
