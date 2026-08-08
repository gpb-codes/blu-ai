import type { ChatRequest, ChatResult, ModelProvider } from "../types.js";

export class GeminiProvider implements ModelProvider {
  readonly id = "gemini" as const;

  listModels(): string[] {
    return ["gemini-flash"];
  }

  async chat(_req: ChatRequest): Promise<ChatResult> {
    // TODO Fase 2: implementar con @google/generative-ai.
    throw new Error("GeminiProvider no implementado (Fase 2)");
  }
}
