// Adapter OpenAI (API oficial, formato chat/completions).

import { OpenAiCompatibleProvider, keyFromEnv } from "./openai-compatible.js";

export class OpenAiProvider extends OpenAiCompatibleProvider {
  constructor() {
    super(
      "openai",
      ["gpt-4o-mini", "gpt-5"],
      {
        baseUrl: "https://api.openai.com/v1",
        label: "openai",
      },
      keyFromEnv("OPENAI_API_KEY"),
    );
  }
}