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

type ProjectsHandler struct {
	uc *usecases.ProjectsUseCase
}

func NewProjectsHandler(uc *usecases.ProjectsUseCase) *ProjectsHandler {
	return &ProjectsHandler{uc: uc}
}

func (h *ProjectsHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	res, err := h.uc.List(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "INTERNAL", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, res)
}

func (h *ProjectsHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	var req dto.CreateProjectRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_REQUEST", "JSON inválido")
		return
	}
	if errs := req.Validate(); len(errs) > 0 {
		writeError(w, http.StatusBadRequest, "VALIDATION_ERROR", errs[0])
		return
	}
	p, err := h.uc.Create(r.Context(), userID, req.Name)
	if err != nil {
		if err == usecases.ErrNameRequired {
			writeError(w, http.StatusBadRequest, "NAME_REQUIRED", err.Error())
			return
		}
		writeError(w, http.StatusInternalServerError, "INTERNAL", err.Error())
		return
	}
	writeJSON(w, http.StatusCreated, p)
}

func (h *ProjectsHandler) Get(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	id := chi.URLParam(r, "id")
	p, err := h.uc.Get(r.Context(), userID, id)
	if err != nil {
		if err == usecases.ErrProjectNotFound {
			writeError(w, http.StatusNotFound, "PROJECT_NOT_FOUND", err.Error())
			return
		}
		if err == usecases.ErrForbidden {
			writeError(w, http.StatusForbidden, "FORBIDDEN_PROJECT", err.Error())
			return
		}
		writeError(w, http.StatusInternalServerError, "INTERNAL", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, p)
}

func (h *ProjectsHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	id := chi.URLParam(r, "id")
	var req dto.UpdateProjectRequest
	_ = json.NewDecoder(r.Body).Decode(&req)
	p, err := h.uc.Update(r.Context(), userID, id, req.Name)
	if err != nil {
		if err == usecases.ErrForbidden {
			writeError(w, http.StatusForbidden, "FORBIDDEN_PROJECT", err.Error())
			return
		}
		writeError(w, http.StatusInternalServerError, "INTERNAL", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, p)
}

func (h *ProjectsHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	id := chi.URLParam(r, "id")
	if err := h.uc.Remove(r.Context(), userID, id); err != nil {
		if err == usecases.ErrForbidden {
			writeError(w, http.StatusForbidden, "FORBIDDEN_PROJECT", err.Error())
			return
		}
		writeError(w, http.StatusInternalServerError, "INTERNAL", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]bool{"ok": true})
}

func (h *ProjectsHandler) Members(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	id := chi.URLParam(r, "id")
	m, err := h.uc.Members(r.Context(), userID, id)
	if err != nil {
		writeError(w, http.StatusForbidden, "FORBIDDEN_PROJECT", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, m)
}

func (h *ProjectsHandler) AddMember(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	id := chi.URLParam(r, "id")
	var req dto.AddMemberRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_REQUEST", "JSON inválido")
		return
	}
	if errs := req.Validate(); len(errs) > 0 {
		writeError(w, http.StatusBadRequest, "VALIDATION_ERROR", errs[0])
		return
	}
	if err := h.uc.AddMember(r.Context(), userID, id, req.UserID, shared.MemberRole(req.Role)); err != nil {
		if err == usecases.ErrAlreadyMember {
			writeError(w, http.StatusConflict, "ALREADY_MEMBER", err.Error())
			return
		}
		writeError(w, http.StatusForbidden, "FORBIDDEN_PROJECT", err.Error())
		return
	}
	writeJSON(w, http.StatusCreated, map[string]bool{"ok": true})
}

func (h *ProjectsHandler) UpdateMember(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	id := chi.URLParam(r, "id")
	target := chi.URLParam(r, "userId")
	var req dto.UpdateMemberRoleRequest
	_ = json.NewDecoder(r.Body).Decode(&req)
	if err := h.uc.UpdateMemberRole(r.Context(), userID, id, target, shared.MemberRole(req.Role)); err != nil {
		writeError(w, http.StatusForbidden, "FORBIDDEN_PROJECT", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]bool{"ok": true})
}

func (h *ProjectsHandler) RemoveMember(w http.ResponseWriter, r *http.Request) {
	userID, _ := mw.UserIDFromContext(r.Context())
	id := chi.URLParam(r, "id")
	target := chi.URLParam(r, "userId")
	if err := h.uc.RemoveMember(r.Context(), userID, id, target); err != nil {
		if err == usecases.ErrLastOwner {
			writeError(w, http.StatusBadRequest, "LAST_OWNER", err.Error())
			return
		}
		writeError(w, http.StatusForbidden, "FORBIDDEN_PROJECT", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]bool{"ok": true})
}
