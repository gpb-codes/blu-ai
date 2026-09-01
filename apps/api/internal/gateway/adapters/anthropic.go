package adapters

import (
	"fmt"
	"os"
	"strings"

	"github.com/blu-ia/api/internal/gateway"
)

type AnthropicProvider struct{}

func (p *AnthropicProvider) ID() gateway.ProviderID { return "anthropic" }
func (p *AnthropicProvider) ListModels() []string   { return []string{"claude-sonnet-5", "claude-opus-4-8"} }

func (p *AnthropicProvider) Chat(req gateway.ChatRequest) (gateway.ChatResult, error) {
	apiKey := ""
	if req.APIKey != nil {
		apiKey = *req.APIKey
	} else {
		apiKey = os.Getenv("ANTHROPIC_API_KEY")
	}
	if apiKey == "" {
		return gateway.ChatResult{}, fmt.Errorf("Sin API key para anthropic (setea la tuya o usa BYOK)")
	}
	var systemParts []string
	var messages []map[string]string
	for _, m := range req.Messages {
		if m.Role == "system" {
			systemParts = append(systemParts, m.Content)
		} else {
			role := m.Role
			if role == "assistant" {
				role = "assistant"
			} else {
				role = "user"
			}
			messages = append(messages, map[string]string{"role": role, "content": m.Content})
		}
	}
	body := map[string]any{
		"model":       req.Model,
		"max_tokens":  4096,
		"temperature": 0.7,
		"messages":    messages,
	}
	if req.MaxTokens != nil {
		body["max_tokens"] = *req.MaxTokens
	}
	if req.Temperature != nil {
		body["temperature"] = *req.Temperature
	}
	if len(systemParts) > 0 {
		body["system"] = strings.Join(systemParts, "\n")
	}
	type respBody struct {
		Content []struct {
			Type *string `json:"type"`
			Text *string `json:"text"`
		} `json:"content"`
		Usage *struct {
			InputTokens  *int `json:"input_tokens"`
			OutputTokens *int `json:"output_tokens"`
		} `json:"usage"`
		Error *struct {
			Message string `json:"message"`
		} `json:"error"`
	}
	data, err := PostJSON[respBody](PostJsonOptions{
		URL:  "https://api.anthropic.com/v1/messages",
		Body: body,
		Headers: map[string]string{
			"x-api-key":         apiKey,
			"anthropic-version": "2023-06-01",
			"x-provider":        "anthropic",
		},
		Ctx: req.Ctx,
	})
	if err != nil {
		return gateway.ChatResult{}, err
	}
	var sb strings.Builder
	for _, b := range data.Content {
		if b.Type != nil && *b.Type == "text" && b.Text != nil {
			sb.WriteString(*b.Text)
			sb.WriteString("\n")
		}
	}
	content := strings.TrimSpace(sb.String())
	if content == "" {
		return gateway.ChatResult{}, &ProviderHttpError{Message: "Respuesta vacía de anthropic", Status: 502, ProviderLabel: "anthropic"}
	}
	var inTok, outTok int
	if data.Usage != nil {
		if data.Usage.InputTokens != nil {
			inTok = *data.Usage.InputTokens
		}
		if data.Usage.OutputTokens != nil {
			outTok = *data.Usage.OutputTokens
		}
	}
	return gateway.ChatResult{
		Content:  content,
		Model:    req.Model,
		Provider: "anthropic",
		Usage:    struct{ InputTokens int `json:"inputTokens"`; OutputTokens int `json:"outputTokens"` }{InputTokens: inTok, OutputTokens: outTok},
	}, nil
}
