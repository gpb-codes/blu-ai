package handlers

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/blu-ia/api/internal/application/usecases"
	"github.com/blu-ia/api/internal/presentation/dto"
	mw "github.com/blu-ia/api/internal/presentation/middleware"
)

type AuthHandler struct {
	uc *usecases.AuthUseCase
}

func NewAuthHandler(uc *usecases.AuthUseCase) *AuthHandler {
	return &AuthHandler{uc: uc}
}

func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	var req dto.RegisterRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_REQUEST", "JSON inválido")
		return
	}
	if errs := req.Validate(); len(errs) > 0 {
		writeError(w, http.StatusBadRequest, "VALIDATION_ERROR", errs[0])
		return
	}
	res, err := h.uc.Register(r.Context(), usecases.RegisterInput{Email: req.Email, Password: req.Password, DisplayName: req.DisplayName})
	if err != nil {
		if errors.Is(err, usecases.ErrEmailTaken) {
			writeError(w, http.StatusConflict, "EMAIL_TAKEN", "El email ya está registrado")
			return
		}
		writeError(w, http.StatusInternalServerError, "INTERNAL", err.Error())
		return
	}
	writeJSON(w, http.StatusCreated, res)
}

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req dto.LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_REQUEST", "JSON inválido")
		return
	}
	if errs := req.Validate(); len(errs) > 0 {
		writeError(w, http.StatusUnauthorized, "INVALID_CREDENTIALS", "Credenciales inválidas")
		return
	}
	res, err := h.uc.Login(r.Context(), usecases.LoginInput{Email: req.Email, Password: req.Password})
	if err != nil {
		if errors.Is(err, usecases.ErrInvalidCredentials) {
			writeError(w, http.StatusUnauthorized, "INVALID_CREDENTIALS", "Credenciales inválidas")
			return
		}
		writeError(w, http.StatusInternalServerError, "INTERNAL", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, res)
}

func (h *AuthHandler) Refresh(w http.ResponseWriter, r *http.Request) {
	var req dto.RefreshRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_REQUEST", "JSON inválido")
		return
	}
	if errs := req.Validate(); len(errs) > 0 {
		writeError(w, http.StatusUnauthorized, "INVALID_REFRESH_TOKEN", "refreshToken inválido")
		return
	}
	res, err := h.uc.Refresh(r.Context(), req.RefreshToken)
	if err != nil {
		if errors.Is(err, usecases.ErrInvalidRefreshToken) {
			writeError(w, http.StatusUnauthorized, "INVALID_REFRESH_TOKEN", "Refresh token inválido")
			return
		}
		writeError(w, http.StatusInternalServerError, "INTERNAL", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, res)
}

func (h *AuthHandler) Logout(w http.ResponseWriter, r *http.Request) {
	var req dto.LogoutRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_REQUEST", "JSON inválido")
		return
	}
	_ = h.uc.Logout(r.Context(), req.RefreshToken)
	writeJSON(w, http.StatusOK, map[string]bool{"ok": true})
}

func (h *AuthHandler) Me(w http.ResponseWriter, r *http.Request) {
	userID, ok := mw.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "UNAUTHORIZED", "No autenticado")
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"id": userID})
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, code, message string) {
	writeJSON(w, status, map[string]string{"code": code, "message": message})
}
