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
  role: "user" | "assistant";
  content: string;
}

export interface ChatResponse {
  text: string;
  usage: {
    credits: number;
    model: string;
    tier: Tier;
  };
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