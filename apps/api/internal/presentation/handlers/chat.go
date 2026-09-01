package handlers

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/blu-ia/api/internal/application/usecases"
	"github.com/blu-ia/api/internal/gateway"
	"github.com/blu-ia/api/internal/presentation/dto"
	mw "github.com/blu-ia/api/internal/presentation/middleware"
	"github.com/blu-ia/api/internal/shared"
)

type ChatHandler struct {
	uc *usecases.ChatUseCase
}

func NewChatHandler(uc *usecases.ChatUseCase) *ChatHandler {
	return &ChatHandler{uc: uc}
}

func (h *ChatHandler) Send(w http.ResponseWriter, r *http.Request) {
	userID, ok := mw.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "UNAUTHORIZED", "No autenticado")
		return
	}
	var req dto.SendMessageRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_REQUEST", "JSON inválido")
		return
	}
	if errs := req.Validate(); len(errs) > 0 {
		writeError(w, http.StatusBadRequest, "VALIDATION_ERROR", errs[0])
		return
	}
	tier := req.Tier
	if tier == "" {
		tier = "auto"
	}
	history := make([]gateway.ProviderMessage, 0, len(req.History))
	for _, h := range req.History {
		role := h.Role
		if role != "user" && role != "assistant" {
			role = "user"
		}
		history = append(history, gateway.ProviderMessage{Role: role, Content: h.Content})
	}
	var agentID *shared.AgentID
	if req.AgentID != nil {
		a := shared.AgentID(*req.AgentID)
		agentID = &a
	}
	res, err := h.uc.Execute(r.Context(), usecases.ChatRequestInput{
		UserID:    userID,
		ProjectID: req.ProjectID,
		AgentID:   agentID,
		Tier:      tier,
		Text:      req.Text,
		History:   history,
	})
	if err != nil {
		msg := err.Error()
		if strings.Contains(msg, "Sin API key") {
			writeError(w, http.StatusServiceUnavailable, "PROVIDER_NOT_CONFIGURED", msg)
			return
		}
		if msg == "Sin acceso a este proyecto" {
			writeError(w, http.StatusForbidden, "FORBIDDEN_PROJECT", msg)
			return
		}
		writeError(w, http.StatusInternalServerError, "INTERNAL", msg)
		return
	}
	writeJSON(w, http.StatusOK, res)
}
