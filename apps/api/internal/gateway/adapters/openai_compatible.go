package adapters

import (
	"fmt"
	"os"

	"github.com/blu-ia/api/internal/gateway"
)

type OpenAICompatibleOptions struct {
	BaseURL      string
	ExtraHeaders map[string]string
	Label        string
}

type OpenAICompatibleProvider struct {
	id         gateway.ProviderID
	models     []string
	opts       OpenAICompatibleOptions
	resolveKey func(req gateway.ChatRequest) *string
}

func NewOpenAICompatible(id gateway.ProviderID, models []string, opts OpenAICompatibleOptions, resolveKey func(gateway.ChatRequest) *string) *OpenAICompatibleProvider {
	return &OpenAICompatibleProvider{id: id, models: models, opts: opts, resolveKey: resolveKey}
}

func (p *OpenAICompatibleProvider) ID() gateway.ProviderID { return p.id }
func (p *OpenAICompatibleProvider) ListModels() []string   { return append([]string(nil), p.models...) }

func (p *OpenAICompatibleProvider) Chat(req gateway.ChatRequest) (gateway.ChatResult, error) {
	apiKey := p.resolveKey(req)
	if apiKey == nil || *apiKey == "" {
		return gateway.ChatResult{}, fmt.Errorf("Sin API key para %s (setea la env o usa BYOK)", p.opts.Label)
	}
	messages := make([]map[string]string, 0, len(req.Messages))
	for _, m := range req.Messages {
		messages = append(messages, map[string]string{"role": m.Role, "content": m.Content})
	}
	body := map[string]any{
		"model":    req.Model,
		"messages": messages,
		"stream":   false,
	}
	if req.Temperature != nil {
		body["temperature"] = *req.Temperature
	} else {
		body["temperature"] = 0.7
	}
	if req.MaxTokens != nil {
		body["max_tokens"] = *req.MaxTokens
	}
	headers := map[string]string{
		"authorization": "Bearer " + *apiKey,
		"x-provider":    p.opts.Label,
	}
	for k, v := range p.opts.ExtraHeaders {
		headers[k] = v
	}
	type respBody struct {
		Choices []struct {
			Message *struct {
				Content *string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
		Usage *struct {
			PromptTokens     *int `json:"prompt_tokens"`
			CompletionTokens *int `json:"completion_tokens"`
		} `json:"usage"`
		Error *struct {
			Message string `json:"message"`
		} `json:"error"`
	}
	data, err := PostJSON[respBody](PostJsonOptions{
		URL:     p.opts.BaseURL + "/chat/completions",
		Body:    body,
		Headers: headers,
		Ctx:     req.Ctx,
	})
	if err != nil {
		return gateway.ChatResult{}, err
	}
	if len(data.Choices) == 0 || data.Choices[0].Message == nil || data.Choices[0].Message.Content == nil {
		return gateway.ChatResult{}, &ProviderHttpError{Message: fmt.Sprintf("Respuesta vacía de %s", p.opts.Label), Status: 502, ProviderLabel: p.opts.Label}
	}
	content := *data.Choices[0].Message.Content
	var inTok, outTok int
	if data.Usage != nil {
		if data.Usage.PromptTokens != nil {
			inTok = *data.Usage.PromptTokens
		}
		if data.Usage.CompletionTokens != nil {
			outTok = *data.Usage.CompletionTokens
		}
	}
	return gateway.ChatResult{
		Content:  content,
		Model:    req.Model,
		Provider: p.id,
		Usage:    struct{ InputTokens int `json:"inputTokens"`; OutputTokens int `json:"outputTokens"` }{InputTokens: inTok, OutputTokens: outTok},
	}, nil
}

func KeyFromEnv(envName string) func(gateway.ChatRequest) *string {
	return func(req gateway.ChatRequest) *string {
		if req.APIKey != nil && *req.APIKey != "" {
			return req.APIKey
		}
		if v := os.Getenv(envName); v != "" {
			return &v
		}
		return nil
	}
}
