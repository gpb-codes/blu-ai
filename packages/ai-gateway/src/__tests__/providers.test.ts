// Pruebas de adapters reales (Fase 2) con fetch mockeado — verifican el mapeo
// de requests/responses de cada proveedor sin llamar a APIs de pago.

import { afterEach, describe, expect, it, vi } from "vitest";
import { AnthropicProvider } from "../adapters/anthropic.js";
import { GeminiProvider } from "../adapters/gemini.js";
import { OpenAiProvider } from "../adapters/openai.js";
import { OpenRouterProvider } from "../adapters/openrouter.js";
import type { ChatRequest } from "../types.js";

function makeReq(overrides: Partial<ChatRequest> = {}): ChatRequest {
  return {
    provider: "openai",
    model: "gpt-4o-mini",
    messages: [{ role: "user", content: "hola" }],
    ...overrides,
  };
}

const OPENAI_RESPONSE = {
  choices: [{ message: { content: "respuesta azul" } }],
  usage: { prompt_tokens: 12, completion_tokens: 34 },
};

/** Mockea fetch global y devuelve la lista de llamadas (url, init). */
function mockFetch(status: number, body: unknown) {
  const calls: Array<{ url: string; init: RequestInit }> = [];
  vi.stubGlobal(
    "fetch",
    vi.fn(async (url: string | URL | Request, init?: RequestInit) => {
      calls.push({ url: String(url), init: init ?? {} });
      return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
    }),
  );
  return calls;
}

function headersOf(init: RequestInit): Record<string, string> {
  return (init.headers ?? {}) as Record<string, string>;
}

afterEach(() => {
  vi.unstubAllGlobals();
  delete process.env.OPENAI_API_KEY;
  delete process.env.ANTHROPIC_API_KEY;
  delete process.env.GEMINI_API_KEY;
  delete process.env.OPENROUTER_API_KEY;
});

describe("OpenAiProvider", () => {
  it("manda chat/completions con la key de env y parsea usage", async () => {
    process.env.OPENAI_API_KEY = "sk-env";
    const calls = mockFetch(200, OPENAI_RESPONSE);
    const r = await new OpenAiProvider().chat(makeReq());
    expect(r.content).toBe("respuesta azul");
    expect(r.usage).toEqual({ inputTokens: 12, outputTokens: 34 });
    const [call] = calls;
    expect(call!.url).toBe("https://api.openai.com/v1/chat/completions");
    expect(headersOf(call!.init).authorization).toBe("Bearer sk-env");
    const body = JSON.parse(String(call!.init.body));
    expect(body).toMatchObject({ model: "gpt-4o-mini", stream: false, temperature: 0.7 });
  });

  it("prioriza la key BYOK sobre la de env", async () => {
    process.env.OPENAI_API_KEY = "sk-env";
    const calls = mockFetch(200, OPENAI_RESPONSE);
    await new OpenAiProvider().chat(makeReq({ apiKey: "sk-byok" }));
    expect(headersOf(calls[0]!.init).authorization).toBe("Bearer sk-byok");
  });

  it("sin key lanza error claro", async () => {
    await expect(new OpenAiProvider().chat(makeReq({ apiKey: undefined }))).rejects.toThrow("Sin API key");
  });

  it("mapea 429 a error de rate limit (para que el router haga fallback)", async () => {
    process.env.OPENAI_API_KEY = "sk-env";
    mockFetch(429, { error: { message: "rate limited" } });
    await expect(new OpenAiProvider().chat(makeReq())).rejects.toThrow("Rate limit");
  });

  it("mapea 401/403 a error de key rechazada", async () => {
    process.env.OPENAI_API_KEY = "sk-env";
    mockFetch(401, { error: { message: "invalid api key" } });
    await expect(new OpenAiProvider().chat(makeReq())).rejects.toThrow("API key rechazada");
  });
});

describe("OpenRouterProvider", () => {
  it("usa el baseUrl de OpenRouter con headers de identidad", async () => {
    process.env.OPENROUTER_API_KEY = "or-env";
    const calls = mockFetch(200, OPENAI_RESPONSE);
    await new OpenRouterProvider().chat(makeReq({ model: "deepseek-chat" }));
    expect(calls[0]!.url).toBe("https://openrouter.ai/api/v1/chat/completions");
    const headers = headersOf(calls[0]!.init);
    expect(headers["x-title"]).toBe("BLU IA");
    expect(headers.authorization).toBe("Bearer or-env");
  });

  it("sirve el modelo de fine-tune de Blu vía OpenRouter", async () => {
    process.env.OPENROUTER_API_KEY = "or-env";
    const calls = mockFetch(200, OPENAI_RESPONSE);
    await new OpenRouterProvider().chat(makeReq({ model: "qwen-finetune-light" }));
    const body = JSON.parse(String(calls[0]!.init.body));
    expect(body.model).toBe("qwen-finetune-light");
  });
});

describe("AnthropicProvider", () => {
  it("separa `system` del array de mensajes y usa x-api-key", async () => {
    process.env.ANTHROPIC_API_KEY = "sk-ant-env";
    const calls = mockFetch(200, {
      content: [{ type: "text", text: "claude responde" }],
      usage: { input_tokens: 5, output_tokens: 7 },
    });
    const r = await new AnthropicProvider().chat(
      makeReq({
        messages: [
          { role: "system", content: "Eres Blu" },
          { role: "user", content: "hola" },
        ],
      }),
    );
    expect(r.content).toBe("claude responde");
    expect(r.usage).toEqual({ inputTokens: 5, outputTokens: 7 });
    const headers = headersOf(calls[0]!.init);
    expect(headers["x-api-key"]).toBe("sk-ant-env");
    expect(headers["anthropic-version"]).toBe("2023-06-01");
    const body = JSON.parse(String(calls[0]!.init.body));
    expect(body.system).toBe("Eres Blu");
    expect(body.messages).toEqual([{ role: "user", content: "hola" }]);
  });

  it("concatena bloques de texto de la respuesta", async () => {
    process.env.ANTHROPIC_API_KEY = "sk-ant-env";
    mockFetch(200, {
      content: [
        { type: "text", text: "uno\n" },
        { type: "text", text: "dos" },
      ],
      usage: { input_tokens: 10, output_tokens: 20 },
    });
    const r = await new AnthropicProvider().chat(makeReq());
    expect(r.content).toBe("uno\n\ndos");
  });
});

describe("GeminiProvider", () => {
  it("arma generateContent con ?key=, roles model/user y systemInstruction", async () => {
    process.env.GEMINI_API_KEY = "gem-env";
    const calls = mockFetch(200, {
      candidates: [{ content: { parts: [{ text: "de gemini" }] } }],
      usageMetadata: { promptTokenCount: 3, candidatesTokenCount: 4 },
    });
    const r = await new GeminiProvider().chat(
      makeReq({
        model: "gemini-flash",
        messages: [
          { role: "system", content: "sys" },
          { role: "assistant", content: "previo" },
          { role: "user", content: "hola" },
        ],
      }),
    );
    expect(r.content).toBe("de gemini");
    expect(r.usage).toEqual({ inputTokens: 3, outputTokens: 4 });
    const [call] = calls;
    expect(call!.url).toContain("/models/gemini-2.5-flash:generateContent");
    expect(call!.url).toContain("key=gem-env");
    const body = JSON.parse(String(call!.init.body));
    expect(body.systemInstruction).toEqual({ parts: [{ text: "sys" }] });
    expect(body.contents).toEqual([
      { role: "model", parts: [{ text: "previo" }] },
      { role: "user", parts: [{ text: "hola" }] },
    ]);
  });
});