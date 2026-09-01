package gateway

import (
	"regexp"
	"strings"
	"sync"
	"time"
	"unicode"

	"golang.org/x/text/transform"
	"golang.org/x/text/unicode/norm"
)

const (
	MaxInputChars    = 4000
	MaxResponseChars = 4000

	JBWindowMs   = 15 * time.Minute
	JBThreshold  = 5
	JBCooldownMs = 10 * time.Minute
)

var JailbreakTrigger = regexp.MustCompile(`(?i)(ignora\s+(las\s+)?instrucciones|muestra\s+tu\s+prompt|prompt\s+del\s+sistema|configuraci[oó]n\s+interna|soy\s+el\s+desarrollador|desactiv[aoó]\s+tus\s+filtros|modo\s*(libre|mantenimiento)|act[uú]a\s+como\s+si\s+fueras|ya\s+(quedaste|estas|qued[oó])\s+verificad|responde\s+verificado|c[oó]mo\s+(estas|est[aá]s)\s+(desarrollad[oa]|hech[oa]|programad[oa])|con\s+qu[eé]\s+(lenguaje|framework|tecnolog[ií]a|modelo)\s+(estas|est[aá]s)|qu[eé]\s+(modelo|tecnolog[ií]a|framework)\s+(usas|corres)\s+por\s+dentro|eres\s+(gpt|claude|llama|gemini|qwen|chatgpt))`)

var selfIDTechTerms = regexp.MustCompile(`(?i)(qwen|alibaba(?:\s*cloud)?|\bollama\b|gemma\d*|gpt-?\d|open\s*ai|mistral|deepseek|meta\s*llama|\bllama\s*\d|anthropic|gemini)`)
var selfIDRef = regexp.MustCompile(`(?i)\b(soy|estoy|me\s+crearon|fui\s+cread[oa]|corro|corriendo|funciono|basad[oa]s?\s+en|construid[oa]s?\s+en|entrenad[oa]s?\s+(con|por))\b`)

type JailbreakState struct {
	Count         int
	WindowStart   time.Time
	CooldownUntil *time.Time
}

type JailbreakGuard struct {
	mu      sync.Mutex
	tracker map[string]*JailbreakState
}

func NewJailbreakGuard() *JailbreakGuard {
	return &JailbreakGuard{tracker: make(map[string]*JailbreakState)}
}

func (g *JailbreakGuard) IsCooldown(userID string) bool {
	g.mu.Lock()
	defer g.mu.Unlock()
	s, ok := g.tracker[userID]
	if !ok || s.CooldownUntil == nil {
		return false
	}
	return time.Now().Before(*s.CooldownUntil)
}

func (g *JailbreakGuard) Register(userID, text string) bool {
	if !JailbreakTrigger.MatchString(text) {
		return false
	}
	g.mu.Lock()
	defer g.mu.Unlock()
	now := time.Now()
	s, ok := g.tracker[userID]
	if !ok {
		s = &JailbreakState{WindowStart: now}
		g.tracker[userID] = s
	}
	if now.Sub(s.WindowStart) > JBWindowMs {
		s.WindowStart = now
		s.Count = 0
	}
	s.Count++
	if s.Count >= JBThreshold {
		t := now.Add(JBCooldownMs)
		s.CooldownUntil = &t
		s.Count = 0
	}
	return s.CooldownUntil != nil && time.Now().Before(*s.CooldownUntil)
}

func LeaksIdentity(text string) bool {
	return selfIDTechTerms.MatchString(text) && selfIDRef.MatchString(text)
}

func normalize(s string) string {
	t := transform.Chain(norm.NFD, transform.RemoveFunc(func(r rune) bool {
		return unicode.Is(unicode.Mn, r)
	}), norm.NFC)
	res, _, _ := transform.String(t, strings.ToLower(s))
	res = regexp.MustCompile(`[^\w\s]`).ReplaceAllString(res, " ")
	res = regexp.MustCompile(`\s+`).ReplaceAllString(res, " ")
	return strings.TrimSpace(res)
}

func Jaccard(a, b string) float64 {
	wa := splitWords(normalize(a))
	wb := splitWords(normalize(b))
	if len(wa) == 0 || len(wb) == 0 {
		return 0
	}
	setA := toSet(wa)
	setB := toSet(wb)
	inter := 0
	for w := range setA {
		if _, ok := setB[w]; ok {
			inter++
		}
	}
	union := len(setA) + len(setB) - inter
	if union == 0 {
		return 0
	}
	return float64(inter) / float64(union)
}

func IsEchoResponse(question, answer string) bool {
	return Jaccard(question, answer) >= 0.6
}

func SanitizeDisplayName(name string) string {
	name = strings.ReplaceAll(name, "\r", " ")
	name = strings.ReplaceAll(name, "\n", " ")
	if len(name) > 64 {
		name = name[:64]
	}
	return name
}

func splitWords(s string) []string {
	if s == "" {
		return nil
	}
	return strings.Fields(s)
}

func toSet(words []string) map[string]struct{} {
	m := make(map[string]struct{}, len(words))
	for _, w := range words {
		if w != "" {
			m[w] = struct{}{}
		}
	}
	return m
}
