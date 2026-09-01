package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/blu-ia/api/internal/application/usecases"
	"github.com/blu-ia/api/internal/presentation/dto"
	mw "github.com/blu-ia/api/internal/presentation/middleware"
)

type VaultHandler struct {
	uc *usecases.VaultUseCase
}

func NewVaultHandler(uc *usecases.VaultUseCase) *VaultHandler { return &VaultHandler{uc: uc} }

func (h *VaultHandler) Notes(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	projectID := r.URL.Query().Get("projectId")
	if projectID == "" {
		projectID = chi.URLParam(r, "projectId")
	}
	res, err := h.uc.Notes(r.Context(), userID, projectID)
	if err != nil {
		writeError(w, http.StatusForbidden, "FORBIDDEN_PROJECT", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, res)
}

func (h *VaultHandler) Search(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	projectID := r.URL.Query().Get("projectId")
	q := r.URL.Query().Get("q")
	res, err := h.uc.Search(r.Context(), userID, projectID, q, 10)
	if err != nil {
		writeError(w, http.StatusForbidden, "FORBIDDEN_PROJECT", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, res)
}

func (h *VaultHandler) Get(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	id := chi.URLParam(r, "id")
	n, err := h.uc.Get(r.Context(), userID, id)
	if err != nil {
		if err == usecases.ErrNoteNotFound {
			writeError(w, http.StatusNotFound, "NOTE_NOT_FOUND", err.Error())
			return
		}
		writeError(w, http.StatusForbidden, "FORBIDDEN_PROJECT", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, n)
}

func (h *VaultHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	var req dto.CreateNoteRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_REQUEST", "JSON inválido")
		return
	}
	if errs := req.Validate(); len(errs) > 0 {
		writeError(w, http.StatusBadRequest, "VALIDATION_ERROR", errs[0])
		return
	}
	n, err := h.uc.Create(r.Context(), userID, req.ProjectID, req.Title, req.BodyMd, req.Tags)
	if err != nil {
		writeError(w, http.StatusForbidden, "FORBIDDEN_PROJECT", err.Error())
		return
	}
	writeJSON(w, http.StatusCreated, n)
}

func (h *VaultHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	id := chi.URLParam(r, "id")
	var raw map[string]json.RawMessage
	_ = json.NewDecoder(r.Body).Decode(&raw)
	var req dto.UpdateNoteRequest
	// detect if tags present
	if _, ok := raw["tags"]; ok {
		req.HasTags = true
		var tags []string
		_ = json.Unmarshal(raw["tags"], &tags)
		req.Tags = tags
	}
	if v, ok := raw["title"]; ok {
		var s string
		_ = json.Unmarshal(v, &s)
		req.Title = &s
	}
	if v, ok := raw["bodyMd"]; ok {
		var s string
		_ = json.Unmarshal(v, &s)
		req.BodyMd = &s
	}
	n, err := h.uc.Update(r.Context(), userID, id, req.Title, req.BodyMd, req.Tags, req.HasTags)
	if err != nil {
		writeError(w, http.StatusForbidden, "FORBIDDEN_PROJECT", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, n)
}

func (h *VaultHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	id := chi.URLParam(r, "id")
	if err := h.uc.Remove(r.Context(), userID, id); err != nil {
		writeError(w, http.StatusForbidden, "FORBIDDEN_PROJECT", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]bool{"ok": true})
}
