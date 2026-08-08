// Contrato de datos compartido entre apps (api, web, mobile, extension, blu-code).
// Fuente de verdad de los tipos que viajan por la API.

export type PlanId = "FREE" | "BYOK" | "CREDITS";
export type Role = "USER" | "ADMIN";
export type MemberRole = "OWNER" | "ADMIN" | "EDITOR" | "VIEWER";

/** Tiers de producto (etiquetas de marca). El modelo real debajo lo decide el gateway. */
export type TierId = "light" | "flash" | "ultra";

export type ProviderId = "anthropic" | "openai" | "gemini" | "openrouter" | "blu-finetune";

export type AgentId = "plan" | "build" | "cowork" | "research" | "qa" | "automation" | "knowledge";

export type ChatRole = "system" | "user" | "assistant";

export interface ChatMessage {
  id: string;
  role: ChatRole;
  content: string;
  model?: string;
  agentId?: AgentId;
  createdAt: string;
  citedNotes?: string[]; // ids de notas del vault usadas como contexto
}

export interface UserProfile {
  id: string;
  email?: string | null;
  phone?: string | null;
  googleSub?: string | null;
  displayName: string;
  timezone: string;
  plan: PlanId;
  tosAcceptedAt: string | null;
  role: Role;
}

export interface ProjectSummary {
  id: string;
  name: string;
  role: MemberRole;
  memberCount: number;
}

export interface NoteSummary {
  id: string;
  title: string;
  tags: string[];
  updatedAt: string;
  updatedBy: string;
  backlinkCount: number;
}

export interface ApiKeyMasked {
  id: string;
  provider: ProviderId;
  maskedKey: string;
  createdAt: string;
}

export interface CreditBalance {
  plan: PlanId;
  credits: number;
  softCaps: Record<string, number>;
  frozen: boolean;
  resetsAt: string | null;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface SendMessageRequest {
  projectId?: string;
  agentId?: AgentId;
  tier?: TierId | "auto";
  messages: ChatMessage[];
}

export interface SendMessageResponse {
  message: ChatMessage;
  usedModel: string;
  citedNotes: string[];
}
