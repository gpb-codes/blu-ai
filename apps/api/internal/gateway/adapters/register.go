package adapters

import "github.com/blu-ia/api/internal/gateway"

func CreateProviders() map[gateway.ProviderID]gateway.ModelProvider {
	m := make(map[gateway.ProviderID]gateway.ModelProvider)
	m["anthropic"] = &AnthropicProvider{}
	m["openai"] = NewOpenAIProvider()
	m["gemini"] = &GeminiProvider{}
	m["openrouter"] = NewOpenRouterProvider()
	// blu-finetune se sirve vía openrouter (mismo provider, modelos fine-tuneados)
	m["blu-finetune"] = NewOpenRouterProvider()
	return m
}
