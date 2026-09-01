package adapters

import (
	"fmt"
	"net/url"
	"os"
	"strings"

	"github.com/blu-ia/api/internal/gateway"
)

var modelAliases = map[string]string{
	"gemini-flash": "gemini-2.5-flash",
}

type GeminiProvider struct{}

func (p *GeminiProvider) ID() gateway.ProviderID { return "gemini" }
func (p *GeminiProvider) ListModels() []string   { return []string{"gemini-flash"} }

func (p *GeminiProvider) Chat(req gateway.ChatRequest) (gateway.ChatResult, error) {
	apiKey := ""
	if req.APIKey != nil {
		apiKey = *req.APIKey
	} else {
		apiKey = os.Getenv("GEMINI_API_KEY")
	}
	if apiKey == "" {
		return gateway.ChatResult{}, fmt.Errorf("Sin API key para gemini (setea la tuya o usa BYOK)")
	}
	model := req.Model
	if alias, ok := modelAliases[req.Model]; ok {
		model = alias
	}
	var systemParts []string
	var contents []map[string]any
	for _, m := range req.Messages {
		if m.Role == "system" {
			systemParts = append(systemParts, m.Content)
		} else {
			role := "user"
			if m.Role == "assistant" {
				role = "model"
			}
			contents = append(contents, map[string]any{
				"role":  role,
				"parts": []map[string]string{{"text": m.Content}},
			})
		}
	}
	body := map[string]any{
		"contents": contents,
		"generationConfig": map[string]any{
			"temperature": func() float64 {
				if req.Temperature != nil {
					return *req.Temperature
				}
				return 0.7
			}(),
		},
	}
	if req.MaxTokens != nil {
		body["generationConfig"].(map[string]any)["maxOutputTokens"] = *req.MaxTokens
	}
	if len(systemParts) > 0 {
		body["systemInstruction"] = map[string]any{"parts": []map[string]string{{"text": strings.Join(systemParts, "\n")}}}
	}
	type respBody struct {
		Candidates []struct {
			Content *struct {
				Parts []struct {
					Text *string `json:"text"`
				} `json:"parts"`
			} `json:"content"`
		} `json:"candidates"`
		UsageMetadata *struct {
			PromptTokenCount     *int `json:"promptTokenCount"`
			CandidatesTokenCount *int `json:"candidatesTokenCount"`
		} `json:"usageMetadata"`
		Error *struct {
			Message string `json:"message"`
		} `json:"error"`
	}
	urlStr := fmt.Sprintf("https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s", url.PathEscape(model), url.QueryEscape(apiKey))
	data, err := PostJSON[respBody](PostJsonOptions{
		URL:     urlStr,
		Body:    body,
		Headers: map[string]string{"x-provider": "gemini"},
		Ctx:     req.Ctx,
	})
	if err != nil {
		return gateway.ChatResult{}, err
	}
	var sb strings.Builder
	if len(data.Candidates) > 0 && data.Candidates[0].Content != nil {
		for _, p := range data.Candidates[0].Content.Parts {
			if p.Text != nil {
				sb.WriteString(*p.Text)
				sb.WriteString("\n")
			}
		}
	}
	content := strings.TrimSpace(sb.String())
	if content == "" {
		return gateway.ChatResult{}, &ProviderHttpError{Message: "Respuesta vacía de gemini", Status: 502, ProviderLabel: "gemini"}
	}
	var inTok, outTok int
	if data.UsageMetadata != nil {
		if data.UsageMetadata.PromptTokenCount != nil {
			inTok = *data.UsageMetadata.PromptTokenCount
		}
		if data.UsageMetadata.CandidatesTokenCount != nil {
			outTok = *data.UsageMetadata.CandidatesTokenCount
		}
	}
	return gateway.ChatResult{
		Content:  content,
		Model:    req.Model,
		Provider: "gemini",
		Usage:    struct{ InputTokens int `json:"inputTokens"`; OutputTokens int `json:"outputTokens"` }{InputTokens: inTok, OutputTokens: outTok},
	}, nil
}
