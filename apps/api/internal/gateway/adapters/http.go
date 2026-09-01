package adapters

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

const HTTPTimeoutMs = 90 * time.Second

type ProviderHttpError struct {
	Message       string
	Status        int
	ProviderLabel string
}

func (e *ProviderHttpError) Error() string { return e.Message }

type PostJsonOptions struct {
	URL     string
	Body    any
	Headers map[string]string
	Ctx     context.Context
	Timeout time.Duration
}

func PostJSON[T any](opts PostJsonOptions) (T, error) {
	var zero T
	timeout := opts.Timeout
	if timeout == 0 {
		timeout = HTTPTimeoutMs
	}
	ctx := opts.Ctx
	if ctx == nil {
		ctx = context.Background()
	}
	ctx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()

	bodyBytes, err := json.Marshal(opts.Body)
	if err != nil {
		return zero, &ProviderHttpError{Message: err.Error(), Status: 0, ProviderLabel: providerLabel(opts.Headers)}
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, opts.URL, bytes.NewReader(bodyBytes))
	if err != nil {
		return zero, &ProviderHttpError{Message: err.Error(), Status: 0, ProviderLabel: providerLabel(opts.Headers)}
	}
	req.Header.Set("Content-Type", "application/json")
	for k, v := range opts.Headers {
		req.Header.Set(k, v)
	}
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return zero, &ProviderHttpError{Message: fmt.Sprintf("Sin conexión con el proveedor: %v", err), Status: 0, ProviderLabel: providerLabel(opts.Headers)}
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(resp.Body)
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		var parsed any
		_ = json.Unmarshal(raw, &parsed)
		return zero, &ProviderHttpError{Message: describeHTTPError(resp.StatusCode, parsed), Status: resp.StatusCode, ProviderLabel: providerLabel(opts.Headers)}
	}
	if len(raw) == 0 {
		return zero, nil
	}
	var parsed T
	if err := json.Unmarshal(raw, &parsed); err != nil {
		return zero, &ProviderHttpError{Message: string(raw[:min(300, len(raw))]), Status: resp.StatusCode, ProviderLabel: providerLabel(opts.Headers)}
	}
	return parsed, nil
}

func providerLabel(h map[string]string) string {
	if v, ok := h["x-provider"]; ok {
		return v
	}
	return "proveedor"
}

func describeHTTPError(status int, body any) string {
	if status == 401 || status == 403 {
		return fmt.Sprintf("API key rechazada (HTTP %d)", status)
	}
	if status == 429 {
		return "Rate limit del proveedor (HTTP 429)"
	}
	msg := extractErrorMessage(body)
	return fmt.Sprintf("Error del proveedor (HTTP %d): %s", status, msg)
}

func extractErrorMessage(body any) string {
	if body == nil {
		return "sin detalle"
	}
	if s, ok := body.(string); ok {
		if len(s) > 300 {
			return s[:300]
		}
		return s
	}
	m, ok := body.(map[string]any)
	if !ok {
		return "sin detalle"
	}
	if errObj, ok := m["error"]; ok {
		if errMap, ok := errObj.(map[string]any); ok {
			if inner, ok := errMap["error"]; ok {
				if innerMap, ok := inner.(map[string]any); ok {
					if msg, ok := innerMap["message"].(string); ok && msg != "" {
						return truncate(msg, 300)
					}
				}
			}
			if msg, ok := errMap["message"].(string); ok && msg != "" {
				return truncate(msg, 300)
			}
			if code, ok := errMap["code"]; ok {
				if s, ok := code.(string); ok && s != "" {
					return s
				}
			}
			if status, ok := errMap["status"]; ok {
				if s, ok := status.(string); ok && s != "" {
					return s
				}
			}
		}
		if s, ok := errObj.(string); ok && s != "" {
			return truncate(s, 300)
		}
	}
	if msg, ok := m["message"].(string); ok && msg != "" {
		return truncate(msg, 300)
	}
	return "sin detalle"
}

func truncate(s string, n int) string {
	if len(s) > n {
		return s[:n]
	}
	return s
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
