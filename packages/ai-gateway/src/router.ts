import type { ProviderId, TierId } from "@blu-ia/shared";
import type { ChatRequest, ChatResult, ModelProvider, TierRoute } from "./types.js";

/**
 * Router de tiers: decide (proveedor, modelo) para cada llamada.
 * La configuración vive en `tierRoutes` — cambiar un modelo NO toca código.
 * Modo "auto": clasifica la tarea (charla/código/investigación) y elige el tier.
 */
export class TierRouter {
  constructor(
    private readonly providers: Map<ProviderId, ModelProvider>,
    private readonly tierRoutes: TierRoute[],
  ) {}

  private routeFor(tier: TierId): TierRoute | undefined {
    return this.tierRoutes.find((r) => r.tier === tier);
  }

  /** Proveedor (y modelo) base que serviría este tier — útil para BYOK (key por proveedor). */
  resolve(tier: TierId): { provider: ProviderId; model: string } | undefined {
    const route = this.routeFor(tier);
    return route?.candidates[0];
  }

  /** Intenta cada candidato del tier en orden hasta que uno responda. */
  async chat(tier: TierId, req: Omit<ChatRequest, "provider" | "model">): Promise<ChatResult> {
    const route = this.routeFor(tier);
    if (!route) throw new Error(`Tier sin ruta configurada: ${tier}`);

    let lastError: unknown;
    for (const candidate of route.candidates) {
      const provider = this.providers.get(candidate.provider);
      if (!provider) continue;
      try {
        return await provider.chat({ ...req, provider: candidate.provider, model: candidate.model });
      } catch (e) {
        lastError = e;
        // siguiente candidato (fallback)
      }
    }
    throw new Error(
      `Todos los modelos del tier ${tier} fallaron: ${lastError instanceof Error && lastError.message ? lastError.message : "sin detalle"}`,
      { cause: lastError },
    );
  }
}

const TASK_HINTS: Array<{ re: RegExp; tier: TierId }> = [
  { re: /\b(c[oó]digo|funci[oó]n|bug|error|api|refactor|commit|deploy|script)\b/i, tier: "flash" },
  { re: /\b(resum[eé]n|investig[ao]|document[ao]|an[aá]lisis|reporte|compara)\b/i, tier: "flash" },
  { re: /\b(hola|buenas|qu[eé] tal|gracias|adi[oó]s)\b/i, tier: "light" },
];

/** Modo Auto: clasificación ligera por pistas léxicas (V1); fase 2 puede usar un clasificador LLM. */
export function classifyTask(text: string): TierId {
  for (const hint of TASK_HINTS) {
    if (hint.re.test(text)) return hint.tier;
  }
  return "light";
}
