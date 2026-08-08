// Pruebas del router de tiers: enrutado, fallback entre candidatos y modo Auto.

import { describe, expect, it } from "vitest";
import { classifyTask, TierRouter } from "../router.js";
import type { ChatResult, ModelProvider, ProviderId } from "../types.js";

function fakeProvider(id: ProviderId, opts: { failWith?: Error; content?: string } = {}): ModelProvider {
  return {
    id,
    listModels: () => [],
    async chat(req): Promise<ChatResult> {
      if (opts.failWith) throw opts.failWith;
      return {
        content: opts.content ?? `respuesta de ${id}`,
        provider: id,
        model: req.model,
        usage: { inputTokens: 10, outputTokens: 20 },
      };
    },
  };
}

function routerWith(providers: ModelProvider[]): TierRouter {
  const map = new Map(providers.map((p) => [p.id, p] as const));
  return new TierRouter(map, [
    {
      tier: "light",
      candidates: [
        { provider: "gemini", model: "gemini-flash" },
        { provider: "openai", model: "gpt-4o-mini" },
      ],
    },
  ]);
}

describe("TierRouter.chat", () => {
  it("usa el primer candidato cuando responde", async () => {
    const router = routerWith([fakeProvider("gemini"), fakeProvider("openai")]);
    const r = await router.chat("light", { messages: [{ role: "user", content: "hola" }] });
    expect(r.provider).toBe("gemini");
    expect(r.model).toBe("gemini-flash");
  });

  it("hace fallback al siguiente candidato si el primero falla", async () => {
    const router = routerWith([
      fakeProvider("gemini", { failWith: new Error("rate limit") }),
      fakeProvider("openai"),
    ]);
    const r = await router.chat("light", { messages: [{ role: "user", content: "hola" }] });
    expect(r.provider).toBe("openai");
    expect(r.model).toBe("gpt-4o-mini");
  });

  it("falla con causa cuando todos los candidatos fallan", async () => {
    const router = routerWith([
      fakeProvider("gemini", { failWith: new Error("a") }),
      fakeProvider("openai", { failWith: new Error("b") }),
    ]);
    await expect(router.chat("light", { messages: [] })).rejects.toThrow("Todos los modelos del tier light fallaron");
  });

  it("salta proveedores no registrados en el mapa", async () => {
    const router = routerWith([fakeProvider("openai")]);
    const r = await router.chat("light", { messages: [] });
    expect(r.provider).toBe("openai");
  });

  it("error si el tier no tiene ruta configurada", async () => {
    const router = routerWith([fakeProvider("gemini")]);
    await expect(router.chat("flash", { messages: [] })).rejects.toThrow("Tier sin ruta configurada: flash");
  });
});

describe("classifyTask (modo Auto)", () => {
  it("clasifica código → flash", () => {
    expect(classifyTask("corrige este bug en el api")).toBe("flash");
    expect(classifyTask("dame un script para deploy")).toBe("flash");
  });

  it("clasifica investigación/resumen → flash", () => {
    expect(classifyTask("haz un resumen de la tesis")).toBe("flash");
    expect(classifyTask("investiga sobre IA generativa")).toBe("flash");
  });

  it("clasifica saludo → light", () => {
    expect(classifyTask("hola blu")).toBe("light");
    expect(classifyTask("gracias!")).toBe("light");
  });

  it("texto sin pistas → light por default", () => {
    expect(classifyTask("cuéntame un chiste")).toBe("light");
  });
});