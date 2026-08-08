// Adapter OpenRouter (reúte los modelos abiertos; también sirve los fine-tunes Blu).
// Es compatible con el formato de OpenAI; añade headers de identificación.

import { OpenAiCompatibleProvider, keyFromEnv } from "./openai-compatible.js";

export class OpenRouterProvider extends OpenAiCompatibleProvider {
  constructor() {
    super(
      "openrouter",
      ["deepseek-chat", "qwen-finetune-light", "gpt-4o-mini", "claude-sonnet-5"],
      {
        baseUrl: "https://openrouter.ai/api/v1",
        label: "openrouter",
        extraHeaders: {
          "x-title": "BLU IA",
          "http-referer": "https://blu-ia.com",
        },
      },
      keyFromEnv("OPENROUTER_API_KEY"),
    );
  }
}