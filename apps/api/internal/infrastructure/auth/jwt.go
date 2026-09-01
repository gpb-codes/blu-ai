package auth

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/blu-ia/api/internal/domain/services"
)

func encodeBase64URL(b []byte) string {
	return base64.RawURLEncoding.EncodeToString(b)
}

type JWTService struct {
	secret           []byte
	accessExpiresIn  time.Duration
	refreshExpiresIn time.Duration
}

func NewJWTService(secret string, accessExp, refreshExp time.Duration) *JWTService {
	return &JWTService{secret: []byte(secret), accessExpiresIn: accessExp, refreshExpiresIn: refreshExp}
}

func (s *JWTService) SignAccessToken(userID string) (string, error) {
	claims := jwt.MapClaims{
		"sub": userID,
		"exp": time.Now().Add(s.accessExpiresIn).Unix(),
		"iat": time.Now().Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(s.secret)
}

func (s *JWTService) VerifyAccessToken(tokenStr string) (string, error) {
	token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (any, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("método de firma inesperado: %v", t.Header["alg"])
		}
		return s.secret, nil
	})
	if err != nil {
		return "", err
	}
	if !token.Valid {
		return "", fmt.Errorf("token inválido")
	}
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return "", fmt.Errorf("claims inválidos")
	}
	sub, ok := claims["sub"].(string)
	if !ok || sub == "" {
		return "", fmt.Errorf("sub faltante")
	}
	return sub, nil
}

func (s *JWTService) GenerateRefreshToken(userID string) (services.TokenPair, error) {
	raw := make([]byte, 48)
	if _, err := rand.Read(raw); err != nil {
		return services.TokenPair{}, err
	}
	token := encodeBase64URL(raw)
	access, err := s.SignAccessToken(userID)
	if err != nil {
		return services.TokenPair{}, err
	}
	return services.TokenPair{
		AccessToken:      access,
		RefreshToken:     token,
		RefreshTokenHash: s.HashRefreshToken(token),
		RefreshExpiresAt: time.Now().Add(s.refreshExpiresIn),
	}, nil
}

func (s *JWTService) HashRefreshToken(token string) string {
	h := sha256.Sum256([]byte(token))
	return hex.EncodeToString(h[:])
}
