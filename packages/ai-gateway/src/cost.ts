// Costeo por llamada (por proveedor/modelo). Precios de referencia por millón de tokens.
// Se usa para: contadores de plan, ledger de créditos y auditoría (ai_usage).

export interface ModelPrice {
  inputPerM: number; // USD por millón de tokens de entrada
  outputPerM: number; // USD por millón de tokens de salida
}

const PRICES: Record<string, ModelPrice> = {
  // Anthropic
  "claude-opus-4-8": { inputPerM: 15, outputPerM: 75 },
  "claude-sonnet-5": { inputPerM: 3, outputPerM: 15 },
  // OpenAI
  "gpt-5": { inputPerM: 1.25, outputPerM: 10 },
  "gpt-4o-mini": { inputPerM: 0.15, outputPerM: 0.6 },
  // Google
  "gemini-flash": { inputPerM: 0.075, outputPerM: 0.3 },
  // Open-source barato
  "deepseek-chat": { inputPerM: 0.27, outputPerM: 1.1 },
  "qwen-finetune-light": { inputPerM: 0.1, outputPerM: 0.3 },
};

export function costUsd(model: string, inputTokens: number, outputTokens: number): number {
  const p = PRICES[model] ?? { inputPerM: 1, outputPerM: 2 }; // default conservador
  return (inputTokens / 1_000_000) * p.inputPerM + (outputTokens / 1_000_000) * p.outputPerM;
}

/** Pesos de créditos por modelo (soft caps del plan CREDITS). */
export const CREDIT_WEIGHTS: Record<string, number> = {
  "gpt-4o-mini": 1,
  "gemini-flash": 1,
  "deepseek-chat": 1,
  "claude-sonnet-5": 15,
  "gpt-5": 25,
  "claude-opus-4-8": 60,
  "qwen-finetune-light": 1,
};

export function creditsForModel(model: string): number {
  return CREDIT_WEIGHTS[model] ?? 5;
}
