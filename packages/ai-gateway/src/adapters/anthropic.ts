// Adaptadores de proveedores: 1 archivo por proveedor, todos implementan ModelProvider.
// Los SDK se instalan según se vayan activando; el contrato ya está fijado.

import type { ChatRequest, ChatResult, ModelProvider } from "../types.js";

export class AnthropicProvider implements ModelProvider {
  readonly id = "anthropic" as const;

  listModels(): string[] {
    return ["claude-sonnet-5", "claude-opus-4-8"];
  }

  async chat(_req: ChatRequest): Promise<ChatResult> {
    // TODO Fase 2: implementar con @anthropic-ai/sdk. La key viene de _req.apiKey (BYOK) o env.
    throw new Error("AnthropicProvider no implementado (Fase 2)");
  }
}
