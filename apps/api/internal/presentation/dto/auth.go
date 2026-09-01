package dto

import (
	"net/mail"
	"regexp"
	"strings"
)

type RegisterRequest struct {
	Email       string `json:"email"`
	Password    string `json:"password"`
	DisplayName string `json:"displayName"`
}

func (r RegisterRequest) Validate() []string {
	var errs []string
	if _, err := mail.ParseAddress(r.Email); err != nil {
		errs = append(errs, "email inválido")
	}
	if len(r.Password) < 8 {
		errs = append(errs, "La contraseña debe tener al menos 8 caracteres")
	}
	if len(r.Password) > 72 {
		errs = append(errs, "password demasiado largo (máx 72)")
	}
	if len(strings.TrimSpace(r.DisplayName)) < 2 {
		errs = append(errs, "displayName mínimo 2 caracteres")
	}
	if len(r.DisplayName) > 60 {
		errs = append(errs, "displayName máximo 60 caracteres")
	}
	return errs
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func (r LoginRequest) Validate() []string {
	var errs []string
	if _, err := mail.ParseAddress(r.Email); err != nil {
		errs = append(errs, "email inválido")
	}
	if len(r.Password) < 8 {
		errs = append(errs, "password inválido")
	}
	return errs
}

var refreshRe = regexp.MustCompile(`^[A-Za-z0-9_-]{40,}$`)

type RefreshRequest struct {
	RefreshToken string `json:"refreshToken"`
}

func (r RefreshRequest) Validate() []string {
	if !refreshRe.MatchString(r.RefreshToken) {
		return []string{"refreshToken inválido"}
	}
	return nil
}

type LogoutRequest struct {
	RefreshToken string `json:"refreshToken"`
}
