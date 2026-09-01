// Tipos compartidos del cliente web. Reflejan el contrato de la API (apps/api).

export type PlanId = "FREE" | "CREDITS" | "BYOK";
export type MemberRole = "OWNER" | "ADMIN" | "EDITOR" | "VIEWER";
export type ProviderId = "anthropic" | "openai" | "gemini" | "openrouter";
export type AgentId = "plan" | "build" | "cowork" | "research" | "qa" | "automation" | "knowledge";
export type Tier = "light" | "flash" | "ultra" | "auto";

export interface UserProfile {
  id: string;
  email: string | null;
  phone: string | null;
  googleSub: string | null;
  displayName: string;
  timezone: string;
  plan: PlanId;
  tosAcceptedAt: string | null;
  role: "USER" | "ADMIN";
}

export interface AuthResult {
  user: UserProfile;
  accessToken: string;
  refreshToken: string;
  refreshTokenHash?: string;
  refreshExpiresAt?: string;
}

export interface ProjectSummary {
  id: string;
  name: string;
  slug: string;
  ownerId: string;
  role: MemberRole;
  memberCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface ProjectMember {
  role: MemberRole;
  user: { id: string; displayName: string; email: string | null };
  createdAt: string;
}

export interface ChatSession {
  id: string;
  projectId: string | null;
  userId: string;
  agentId: AgentId | null;
  title: string;
  createdAt: string;
  updatedAt: string;
}

export interface ChatMessage {
  id?: string;
  role: "user" | "assistant" | "tool" | "system";
  content: string;
  createdAt?: string;
  // Evolución a bloques (P0): si existe `blocks`, renderiza bloques en lugar de `content`
  blocks?: MessageBlock[];
  metadata?: MessageMetadata;
}

export type MessageBlock =
  | { type: "text"; text: string }
  | { type: "markdown"; text: string }
  | { type: "code"; code: string; lang?: string }
  | { type: "image"; url: string; alt?: string }
  | { type: "file"; name: string; url: string; mime?: string }
  | { type: "citation"; text: string; source?: string }
  | { type: "tool_call"; name: string; input?: string; output?: string }
  | { type: "thinking"; text: string }
  | { type: "artifact"; id: string; title: string; html?: string }
  | { type: "error"; message: string };

export interface MessageMetadata {
  model?: string;
  agentId?: AgentId;
  citedNotes?: string[];
  usage?: { credits: number; model: string; tier: Tier };
}

export interface ChatResponse {
  text: string;
  blocks?: MessageBlock[];
  usage: {
    credits: number;
    model: string;
    tier: Tier;
  };
}

// Streaming events preparados para SSE (no rompe POST /chat actual)
export type StreamEvent =
  | { type: "message.start"; id: string; role: "assistant" }
  | { type: "text.delta"; delta: string }
  | { type: "thinking.start"; text?: string }
  | { type: "tool.start"; name: string }
  | { type: "tool.output"; output: string }
  | { type: "citation.add"; text: string; source?: string }
  | { type: "artifact.start"; id: string; title: string }
  | { type: "artifact.delta"; html: string }
  | { type: "artifact.complete" }
  | { type: "message.complete"; blocks?: MessageBlock[] }
  | { type: "message.error"; error: string };

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
  grantsPerDay: number;
  credits: number;
  frozen: boolean;
  resetsAt: string | null;
  softCaps: Record<string, number>;
}

export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public code?: string,
  ) {
    super(message);
    this.name = "ApiError";
  }
}