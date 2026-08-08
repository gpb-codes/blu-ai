// Capa de seguridad heredada del bot de WhatsApp (probada en producción jul-2026):
// - anti-jailbreak con cooldown por usuario
// - filtro de fuga de identidad (nunca revelar modelo/tecnología por debajo)
// - anti-eco (Jaccard) para respuestas que repiten la pregunta
// - límites de longitud

export const MAX_INPUT_CHARS = 4000;
export const MAX_RESPONSE_CHARS = 4000;

// Pistas de jailbreak / intentos de sacar el prompt o la tecnología interna.
export const JAILBREAK_TRIGGER =
  /(ignora\s+(las\s+)?instrucciones|muestra\s+tu\s+prompt|prompt\s+del\s+sistema|configuraci[oó]n\s+interna|soy\s+el\s+desarrollador|desactiv[aoó]\s+tus\s+filtros|modo\s*(libre|mantenimiento)|act[uú]a\s+como\s+si\s+fueras|ya\s+(quedaste|estas|qued[oó])\s+verificad|responde\s+verificado|c[oó]mo\s+(estas|est[aá]s)\s+(desarrollad[oa]|hech[oa]|programad[oa])|con\s+qu[eé]\s+(lenguaje|framework|tecnolog[ií]a|modelo)\s+(estas|est[aá]s)|qu[eé]\s+(modelo|tecnolog[ií]a|framework)\s+(usas|corres)\s+por\s+dentro|eres\s+(gpt|claude|llama|gemini|qwen|chatgpt))/i;

const SELF_ID_TECH_TERMS =
  /(qwen|alibaba(?:\s*cloud)?|\bollama\b|gemma\d*|gpt-?\d|open\s*ai|mistral|deepseek|meta\s*llama|\bllama\s*\d|anthropic|gemini)/i;
const SELF_ID_REF =
  /\b(soy|estoy|me\s+crearon|fui\s+cread[oa]|corro|corriendo|funciono|basad[oa]s?\s+en|construid[oa]s?\s+en|entrenad[oa]s?\s+(con|por))\b/i;

export interface JailbreakState {
  count: number;
  windowStart: number;
  cooldownUntil: number | null;
}

export const JB_WINDOW_MS = 15 * 60 * 1000;
export const JB_THRESHOLD = 5;
export const JB_COOLDOWN_MS = 10 * 60 * 1000;

export class JailbreakGuard {
  private tracker = new Map<string, JailbreakState>();

  /** true si el usuario está en cooldown (contestar línea corta sin llamar al modelo). */
  isCooldown(userId: string): boolean {
    const s = this.tracker.get(userId);
    return Boolean(s?.cooldownUntil && Date.now() < s.cooldownUntil);
  }

  register(userId: string, text: string): boolean {
    const now = Date.now();
    const s = this.tracker.get(userId) ?? { count: 0, windowStart: now, cooldownUntil: null };
    if (!JAILBREAK_TRIGGER.test(text)) return false;
    if (now - s.windowStart > JB_WINDOW_MS) {
      s.windowStart = now;
      s.count = 0;
    }
    s.count += 1;
    if (s.count >= JB_THRESHOLD) {
      s.cooldownUntil = now + JB_COOLDOWN_MS;
      s.count = 0;
    }
    this.tracker.set(userId, s);
    return s.cooldownUntil !== null;
  }
}

/** Descarta respuestas que se autodescriben con un modelo/proveedor real. */
export function leaksIdentity(text: string): boolean {
  return SELF_ID_TECH_TERMS.test(text) && SELF_ID_REF.test(text);
}

function normalize(s: string): string {
  return (s || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^\w\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

/** Similitud de Jaccard entre dos textos (para detectar respuestas-eco). */
export function jaccard(a: string, b: string): number {
  const wa = new Set(normalize(a).split(" ").filter(Boolean));
  const wb = new Set(normalize(b).split(" ").filter(Boolean));
  if (!wa.size || !wb.size) return 0;
  let inter = 0;
  for (const w of wa) if (wb.has(w)) inter++;
  return inter / (wa.size + wb.size - inter);
}

export function isEchoResponse(question: string, answer: string): boolean {
  return jaccard(question, answer) >= 0.6;
}

export function sanitizeDisplayName(name: string): string {
  return name.replace(/[\r\n]/g, " ").slice(0, 64);
}
