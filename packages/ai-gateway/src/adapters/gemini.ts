// Adapter Gemini (REST de Google: generateContent con ?key=).
// Internamente "gemini-flash" se traduce a un id real de la API v1beta.

import { postJson, ProviderHttpError } from "./http.js";
import type { ChatRequest, ChatResult, ModelProvider } from "../types.js";

const MODEL_ALIASES: Record<string, string> = {
  "gemini-flash": "gemini-2.5-flash",
};

export class GeminiProvider implements ModelProvider {
  readonly id = "gemini" as const;

  listModels(): string[] {
    return ["gemini-flash"];
  }

  async chat(req: ChatRequest): Promise<ChatResult> {
    const apiKey = req.apiKey ?? process.env.GEMINI_API_KEY;
    if (!apiKey) throw new Error("Sin API key para gemini (setea la tuya o usa BYOK)");

    const model = MODEL_ALIASES[req.model] ?? req.model;

    const system = req.messages.filter((m) => m.role === "system").map((m) => m.content).join("\n");
    const contents = req.messages
      .filter((m) => m.role !== "system")
      .map((m) => ({ role: m.role === "assistant" ? "model" : "user", parts: [{ text: m.content }] }));

    const data = await postJson<{
      candidates?: Array<{ content?: { parts?: Array<{ text?: string }> } }>;
      usageMetadata?: { promptTokenCount?: number; candidatesTokenCount?: number };
      error?: { message?: string };
    }>({
      url: `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(apiKey)}`,
      body: {
        contents,
        ...(system ? { systemInstruction: { parts: [{ text: system }] } } : {}),
        generationConfig: {
          temperature: req.temperature ?? 0.7,
          ...(req.maxTokens ? { maxOutputTokens: req.maxTokens } : {}),
        },
      },
      headers: { "x-provider": "gemini" },
      signal: req.signal,
    });

    const content = (data.candidates?.[0]?.content?.parts ?? [])
      .map((p) => p.text ?? "")
      .join("\n");

    if (!content) throw new ProviderHttpError("Respuesta vacía de gemini", 502, "gemini");

    return {
      content,
      model: req.model,
      provider: "gemini",
      usage: {
        inputTokens: data.usageMetadata?.promptTokenCount ?? 0,
        outputTokens: data.usageMetadata?.candidatesTokenCount ?? 0,
      },
    };
  }
}