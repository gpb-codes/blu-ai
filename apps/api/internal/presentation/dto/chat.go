package dto

import "strings"

var validTiers = map[string]bool{"light": true, "flash": true, "ultra": true, "auto": true}
var validAgents = map[string]bool{"plan": true, "build": true, "cowork": true, "research": true, "qa": true, "automation": true, "knowledge": true}

type HistoryItem struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type SendMessageRequest struct {
	ProjectID *string       `json:"projectId"`
	AgentID   *string       `json:"agentId"`
	Tier      string        `json:"tier"`
	Text      string        `json:"text"`
	History   []HistoryItem `json:"history"`
}

func (r SendMessageRequest) Validate() []string {
	var errs []string
	if r.Tier == "" {
		r.Tier = "auto"
	}
	if !validTiers[r.Tier] {
		errs = append(errs, "tier inválido (light|flash|ultra|auto)")
	}
	if r.AgentID != nil && !validAgents[*r.AgentID] {
		errs = append(errs, "agentId inválido")
	}
	if len(strings.TrimSpace(r.Text)) == 0 {
		errs = append(errs, "text requerido")
	}
	if len(r.Text) > 30000 {
		errs = append(errs, "text máximo 30000 caracteres")
	}
	for i, h := range r.History {
		if h.Role != "user" && h.Role != "assistant" {
			errs = append(errs, "history["+itoa(i)+"].role inválido")
		}
		if len(h.Content) > 100000 {
			errs = append(errs, "history contenido demasiado largo")
		}
	}
	return errs
}

func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	var b [20]byte
	pos := len(b)
	for n > 0 {
		pos--
		b[pos] = byte('0' + n%10)
		n /= 10
	}
	return string(b[pos:])
}
