// AI Gateway — capa única de entrada para toda la IA de la plataforma.
// Tiers Blu + proveedores externos + modo Auto + seguridad + costeo.

export * from "./types.js";
export { TierRouter, classifyTask } from "./router.js";
export { JailbreakGuard, leaksIdentity, isEchoResponse, sanitizeDisplayName, MAX_INPUT_CHARS, JAILBREAK_TRIGGER } from "./security.js";
export { costUsd, creditsForModel, CREDIT_WEIGHTS } from "./cost.js";
export { createProviders } from "./adapters/index.js";

import { classifyTask, TierRouter } from "./router.js";
import { costUsd, creditsForModel } from "./cost.js";
import { MAX_INPUT_CHARS } from "./security.js";
import type { ChatResult } from "./types.js";
import type { GatewayContext, UsageRecord } from "./types.js";

export interface ChatInvocation {
  userId: string;
  plan: "FREE" | "BYOK" | "CREDITS";
  tier: "light" | "flash" | "ultra" | "auto";
  text: string;
  history: Array<{ role: "user" | "assistant"; content: string }>;
  userApiKeys?: GatewayContext["userApiKeys"];
}

export interface ChatInvocationResult {
  content: string;
  usage: UsageRecord;
  creditsSpent: number;
}

/**
 * Punto de entrada del gateway: resuelve tier (o Auto), ejecuta con fallback,
 * aplica seguridad y devuelve el costeo. Usado por application/use-cases del API.
 */
export async function invokeChat(gateway: TierRouter, ctx: ChatInvocation): Promise<ChatInvocationResult> {
  if (ctx.text.length > MAX_INPUT_CHARS) {
    throw new Error(`Mensaje demasiado largo (máx ${MAX_INPUT_CHARS} caracteres)`);
  }

  const tier = ctx.tier === "auto" ? classifyTask(ctx.text) : ctx.tier;

  // BYOK: la key del usuario se pasa al proveedor principal del tier resuelto.
  const primary = gateway.resolve(tier);
  const apiKey = primary ? ctx.userApiKeys?.[primary.provider] : undefined;

  const result: ChatResult = await gateway.chat(tier, {
    messages: [
      ...ctx.history.map((m) => ({ role: m.role, content: m.content })),
      { role: "user", content: ctx.text },
    ],
    apiKey,
  });

  return {
    content: result.content,
    usage: {
      userId: ctx.userId,
      provider: result.provider,
      model: result.model,
      inputTokens: result.usage.inputTokens,
      outputTokens: result.usage.outputTokens,
      costUsd: costUsd(result.model, result.usage.inputTokens, result.usage.outputTokens),
      billedBy: ctx.plan === "BYOK" ? "user" : "blu",
    },
    creditsSpent: creditsForModel(result.model),
  };
}
