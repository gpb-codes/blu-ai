package gateway

import (
	"fmt"
	"regexp"
)

type TierRouter struct {
	providers  map[ProviderID]ModelProvider
	tierRoutes []TierRouteDef
}

func NewTierRouter(providers map[ProviderID]ModelProvider, routes []TierRouteDef) *TierRouter {
	return &TierRouter{providers: providers, tierRoutes: routes}
}

func DefaultTierRoutes() []TierRouteDef {
	return []TierRouteDef{
		{Tier: "light", Candidates: []TierRouteCandidate{{Provider: "gemini", Model: "gemini-flash"}}},
		{Tier: "flash", Candidates: []TierRouteCandidate{{Provider: "openai", Model: "gpt-4o-mini"}}},
		{Tier: "ultra", Candidates: []TierRouteCandidate{{Provider: "anthropic", Model: "claude-sonnet-5"}}},
	}
}

func (r *TierRouter) routeFor(tier TierID) *TierRouteDef {
	for i := range r.tierRoutes {
		if r.tierRoutes[i].Tier == tier {
			return &r.tierRoutes[i]
		}
	}
	return nil
}

func (r *TierRouter) Resolve(tier TierID) *TierRouteCandidate {
	route := r.routeFor(tier)
	if route == nil || len(route.Candidates) == 0 {
		return nil
	}
	c := route.Candidates[0]
	return &c
}

func (r *TierRouter) Chat(tier TierID, req ChatRequest) (ChatResult, error) {
	route := r.routeFor(tier)
	if route == nil {
		return ChatResult{}, fmt.Errorf("tier sin ruta configurada: %s", tier)
	}
	var lastErr error
	for _, cand := range route.Candidates {
		provider, ok := r.providers[cand.Provider]
		if !ok {
			continue
		}
		req.Provider = cand.Provider
		req.Model = cand.Model
		res, err := provider.Chat(req)
		if err == nil {
			return res, nil
		}
		lastErr = err
	}
	if lastErr != nil {
		return ChatResult{}, fmt.Errorf("todos los modelos del tier %s fallaron: %w", tier, lastErr)
	}
	return ChatResult{}, fmt.Errorf("todos los modelos del tier %s fallaron: sin detalle", tier)
}

var taskHints = []struct {
	re   *regexp.Regexp
	tier TierID
}{
	{regexp.MustCompile(`(?i)\b(c[oó]digo|funci[oó]n|bug|error|api|refactor|commit|deploy|script)\b`), "flash"},
	{regexp.MustCompile(`(?i)\b(resum[eé]n|investig[ao]|document[ao]|an[aá]lisis|reporte|compara)\b`), "flash"},
	{regexp.MustCompile(`(?i)\b(hola|buenas|qu[eé] tal|gracias|adi[oó]s)\b`), "light"},
}

func ClassifyTask(text string) TierID {
	for _, h := range taskHints {
		if h.re.MatchString(text) {
			return h.tier
		}
	}
	return "light"
}
