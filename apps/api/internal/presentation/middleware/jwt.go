package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/blu-ia/api/internal/infrastructure/auth"
)

type contextKey string

const UserIDKey contextKey = "userID"

func JWTAuth(jwtSvc *auth.JWTService) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			h := r.Header.Get("Authorization")
			if h == "" {
				http.Error(w, `{"code":"UNAUTHORIZED","message":"Falta token"}`, http.StatusUnauthorized)
				return
			}
			parts := strings.SplitN(h, " ", 2)
			if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
				http.Error(w, `{"code":"UNAUTHORIZED","message":"Formato de token inválido"}`, http.StatusUnauthorized)
				return
			}
			userID, err := jwtSvc.VerifyAccessToken(parts[1])
			if err != nil {
				http.Error(w, `{"code":"UNAUTHORIZED","message":"Token inválido o expirado"}`, http.StatusUnauthorized)
				return
			}
			ctx := context.WithValue(r.Context(), UserIDKey, userID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func UserIDFromContext(ctx context.Context) (string, bool) {
	id, ok := ctx.Value(UserIDKey).(string)
	return id, ok
}
