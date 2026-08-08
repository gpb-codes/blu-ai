// Adapter Anthropic (Messages API /v1/messages).
// El campo `system` se separa del array de mensajes por formato del proveedor.

import { postJson, ProviderHttpError } from "./http.js";
import type { ChatRequest, ChatResult, ModelProvider } from "../types.js";

export class AnthropicProvider implements ModelProvider {
  readonly id = "anthropic" as const;

  listModels(): string[] {
    return ["claude-sonnet-5", "claude-opus-4-8"];
  }

  async chat(req: ChatRequest): Promise<ChatResult> {
    const apiKey = req.apiKey ?? process.env.ANTHROPIC_API_KEY;
    if (!apiKey) throw new Error("Sin API key para anthropic (setea la tuya o usa BYOK)");

    const system = req.messages.filter((m) => m.role === "system").map((m) => m.content).join("\n");
    const messages = req.messages
      .filter((m) => m.role !== "system")
      .map((m) => ({ role: m.role === "assistant" ? "assistant" : "user", content: m.content }));

    const data = await postJson<{
      content?: Array<{ type?: string; text?: string }>;
      error?: { message?: string };
      usage?: { input_tokens?: number; output_tokens?: number };
    }>({
      url: "https://api.anthropic.com/v1/messages",
      body: {
        model: req.model,
        max_tokens: req.maxTokens ?? 4096,
        temperature: req.temperature ?? 0.7,
        messages,
        ...(system ? { system } : {}),
      },
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
        "x-provider": "anthropic",
      },
      signal: req.signal,
    });

    const content = (data.content ?? [])
      .filter((b) => b.type === "text" && typeof b.text === "string")
      .map((b) => b.text)
      .join("\n");

    if (!content) throw new ProviderHttpError("Respuesta vacía de anthropic", 502, "anthropic");

    return {
      content,
      model: req.model,
      provider: "anthropic",
      usage: {
        inputTokens: data.usage?.input_tokens ?? 0,
        outputTokens: data.usage?.output_tokens ?? 0,
      },
    };
  }
}