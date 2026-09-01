package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/blu-ia/api/internal/application/usecases"
	"github.com/blu-ia/api/internal/presentation/dto"
	mw "github.com/blu-ia/api/internal/presentation/middleware"
	"github.com/blu-ia/api/internal/shared"
)

type UserHandler struct {
	uc *usecases.UserUseCase
}

func NewUserHandler(uc *usecases.UserUseCase) *UserHandler { return &UserHandler{uc: uc} }

func (h *UserHandler) Profile(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	p, err := h.uc.Profile(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusNotFound, "USER_NOT_FOUND", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, p)
}

func (h *UserHandler) UpdateProfile(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	var req dto.UpdateProfileRequest
	_ = json.NewDecoder(r.Body).Decode(&req)
	p, err := h.uc.UpdateProfile(r.Context(), userID, req.DisplayName, req.Timezone)
	if err != nil {
		writeError(w, http.StatusNotFound, "USER_NOT_FOUND", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, p)
}

func (h *UserHandler) ApiKeys(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	keys, err := h.uc.ApiKeys(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "INTERNAL", err.Error())
		return
	}
	if keys == nil {
		writeJSON(w, http.StatusOK, []shared.ProviderID{})
		return
	}
	writeJSON(w, http.StatusOK, keys)
}

func (h *UserHandler) AddApiKey(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	var req dto.AddApiKeyRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_REQUEST", "JSON inválido")
		return
	}
	k, err := h.uc.AddApiKey(r.Context(), userID, req.Provider, req.Key)
	if err != nil {
		switch err {
		case usecases.ErrKeyRequired:
			writeError(w, http.StatusBadRequest, "KEY_REQUIRED", err.Error())
		case usecases.ErrProviderNotSupported:
			writeError(w, http.StatusBadRequest, "PROVIDER_NOT_SUPPORTED", err.Error())
		case usecases.ErrApiKeyExists:
			writeError(w, http.StatusConflict, "API_KEY_EXISTS", err.Error())
		default:
			writeError(w, http.StatusInternalServerError, "INTERNAL", err.Error())
		}
		return
	}
	writeJSON(w, http.StatusCreated, k)
}

func (h *UserHandler) RemoveApiKey(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	provider := shared.ProviderID(chi.URLParam(r, "provider"))
	_ = h.uc.RemoveApiKey(r.Context(), userID, provider)
	writeJSON(w, http.StatusOK, map[string]bool{"ok": true})
}

func (h *UserHandler) Credits(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	res, err := h.uc.Credits(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusNotFound, "USER_NOT_FOUND", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, res)
}
