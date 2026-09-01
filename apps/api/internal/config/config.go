package config

import (
	"os"
	"strings"
	"time"
)

type Config struct {
	Port         string
	DatabaseURL  string
	JWTSecret    string
	JWTExpiresIn time.Duration
	JWTRefreshExpiresIn time.Duration
	CORSOrigin   []string
	AnthropicKey string
	OpenAIKey    string
	GeminiKey    string
	OpenRouterKey string
}

func Load() Config {
	port := envOr("PORT", "3000")
	dbURL := envOr("DATABASE_URL", "postgresql://postgres:blu_local_dev@localhost:5434/blu_ia")
	jwtSecret := envOr("JWT_SECRET", "dev-secret-change-me")
	return Config{
		Port:                port,
		DatabaseURL:         dbURL,
		JWTSecret:           jwtSecret,
		JWTExpiresIn:        parseDuration(envOr("JWT_EXPIRES_IN", "15m"), 15*time.Minute),
		JWTRefreshExpiresIn: parseDuration(envOr("JWT_REFRESH_EXPIRES_IN", "30d"), 30*24*time.Hour),
		CORSOrigin:          splitCSV(envOr("CORS_ORIGIN", "")),
		AnthropicKey:        os.Getenv("ANTHROPIC_API_KEY"),
		OpenAIKey:           os.Getenv("OPENAI_API_KEY"),
		GeminiKey:           os.Getenv("GEMINI_API_KEY"),
		OpenRouterKey:       os.Getenv("OPENROUTER_API_KEY"),
	}
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func splitCSV(s string) []string {
	if s == "" {
		return nil
	}
	parts := strings.Split(s, ",")
	out := make([]string, 0, len(parts))
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p != "" {
			out = append(out, p)
		}
	}
	return out
}

func parseDuration(s string, fallback time.Duration) time.Duration {
	if d, err := time.ParseDuration(s); err == nil {
		return d
	}
	return fallback
}
