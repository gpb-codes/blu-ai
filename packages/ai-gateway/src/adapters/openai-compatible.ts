// Cliente OpenAI-compatible: base compartida por OpenAI y OpenRouter.
// Convierte el contrato interno (ChatRequest) al formato /v1/chat/completions.

import { postJson, ProviderHttpError } from "./http.js";
import type { ChatRequest, ChatResult, ModelProvider, ProviderId } from "../types.js";

export interface OpenAiCompatibleOptions {
  baseUrl: string;
  extraHeaders?: Record<string, string>;
  label: string;
}

export class OpenAiCompatibleProvider implements ModelProvider {
  readonly id: ProviderId;

  constructor(
    id: ProviderId,
    private readonly models: string[],
    private readonly opts: OpenAiCompatibleOptions,
    private readonly resolveKey: (req: ChatRequest) => string | undefined,
  ) {
    this.id = id;
  }

  listModels(): string[] {
    return [...this.models];
  }

  async chat(req: ChatRequest): Promise<ChatResult> {
    const apiKey = this.resolveKey(req);
    if (!apiKey) throw new Error(`Sin API key para ${this.opts.label} (setea la env o usa BYOK)`);

    const messages = req.messages.map((m) => ({ role: m.role, content: m.content }));

    const data = await postJson<{
      choices?: Array<{ message?: { content?: string } }>;
      error?: { message?: string };
      usage?: { prompt_tokens?: number; completion_tokens?: number };
    }>({
      url: `${this.opts.baseUrl}/chat/completions`,
      body: {
        model: req.model,
        messages,
        stream: false,
        temperature: req.temperature ?? 0.7,
        ...(req.maxTokens ? { max_tokens: req.maxTokens } : {}),
      },
      headers: {
        authorization: `Bearer ${apiKey}`,
        "x-provider": this.opts.label,
        ...this.opts.extraHeaders,
      },
      signal: req.signal,
    });

    const content = data.choices?.[0]?.message?.content;
    if (content === undefined || content === null) {
      throw new ProviderHttpError(`Respuesta vacía de ${this.opts.label}`, 0, this.opts.label);
    }

    return {
      content,
      model: req.model,
      provider: this.id,
      usage: {
        inputTokens: data.usage?.prompt_tokens ?? 0,
        outputTokens: data.usage?.completion_tokens ?? 0,
      },
    };
  }
}

/** Key del usuario (BYOK) o de la plataforma según env var. */
export function keyFromEnv(envName: string) {
  return (req: ChatRequest): string | undefined => {
    if (req.apiKey) return req.apiKey;
    return process.env[envName];
  };
}