import type { ModelProvider, ProviderId } from "../types.js";
import { AnthropicProvider } from "./anthropic.js";
import { GeminiProvider } from "./gemini.js";
import { OpenAiProvider } from "./openai.js";
import { OpenRouterProvider } from "./openrouter.js";

const FACTORIES: Record<ProviderId, () => ModelProvider> = {
  anthropic: () => new AnthropicProvider(),
  openai: () => new OpenAiProvider(),
  gemini: () => new GeminiProvider(),
  openrouter: () => new OpenRouterProvider(),
  "blu-finetune": () => new OpenRouterProvider(), // los fine-tunes Blu se sirven vía OpenRouter
};

export function createProviders(): Map<ProviderId, ModelProvider> {
  const map = new Map<ProviderId, ModelProvider>();
  for (const [id, factory] of Object.entries(FACTORIES)) {
    map.set(id as ProviderId, factory());
  }
  return map;
}
