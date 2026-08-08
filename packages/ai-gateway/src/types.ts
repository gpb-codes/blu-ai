import type { ProviderId, TierId } from "@blu-ia/shared";

export type { ProviderId, TierId } from "@blu-ia/shared";

export interface ProviderMessage {
  role: "system" | "user" | "assistant";
  content: string;
}

export interface ChatRequest {
  provider: ProviderId;
  model: string;
  messages: ProviderMessage[];
  temperature?: number;
  maxTokens?: number;
  apiKey?: string; // BYOK: key del usuario; si no va, se usa la key de la plataforma
  signal?: AbortSignal;
}

export interface ChatResult {
  content: string;
  model: string;
  provider: ProviderId;
  usage: { inputTokens: number; outputTokens: number };
}

/** Interfaz única que debe implementar cada proveedor (1 archivo por proveedor). */
export interface ModelProvider {
  readonly id: ProviderId;
  /** Modelos que puede servir este proveedor. */
  listModels(): string[];
  chat(req: ChatRequest): Promise<ChatResult>;
}

/** Config de tier → lista de (proveedor, modelo) en orden de preferencia (fallback). */
export interface TierRoute {
  tier: TierId;
  candidates: Array<{ provider: ProviderId; model: string }>;
}

export interface GatewayContext {
  userId?: string;
  plan: "FREE" | "BYOK" | "CREDITS";
  tier: TierId | "auto";
  agentId?: string;
  userApiKeys?: Partial<Record<ProviderId, string>>;
}

export interface UsageRecord {
  userId: string;
  provider: ProviderId;
  model: string;
  inputTokens: number;
  outputTokens: number;
  costUsd: number;
  billedBy: "blu" | "user"; // plan BYOK = el usuario paga a su proveedor
}
