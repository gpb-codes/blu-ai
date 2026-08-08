import type { ChatRequest, ChatResult, ModelProvider } from "../types.js";

export class OpenAiProvider implements ModelProvider {
  readonly id = "openai" as const;

  listModels(): string[] {
    return ["gpt-5", "gpt-4o-mini"];
  }

  async chat(_req: ChatRequest): Promise<ChatResult> {
    // TODO Fase 2: implementar con openai SDK.
    throw new Error("OpenAiProvider no implementado (Fase 2)");
  }
}
