import type { ChatRequest, ChatResult, ModelProvider } from "../types.js";

/** Proveedor genérico que habla con cualquier modelo (incluidos los fine-tunes Blu). */
export class OpenRouterProvider implements ModelProvider {
  readonly id = "openrouter" as const;

  listModels(): string[] {
    return ["deepseek/deepseek-chat", "qwen/qwen-finetune-light"];
  }

  async chat(_req: ChatRequest): Promise<ChatResult> {
    // TODO Fase 2: implementar con fetch a https://openrouter.ai/api/v1/chat/completions.
    throw new Error("OpenRouterProvider no implementado (Fase 2)");
  }
}
