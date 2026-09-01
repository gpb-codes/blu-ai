// Cliente HTTP de la API de BLU. Guarda tokens planos (contrato real del backend)
// y hace refresh automático en 401. Lanza ApiError con mensaje en español.

import {
  ApiError,
  type AgentId,
  type ApiKeyMasked,
  type AuthResult,
  type ChatMessage,
  type ChatResponse,
  type ChatSession,
  type CreditBalance,
  type MemberRole,
  type NoteSummary,
  type ProjectMember,
  type ProjectSummary,
  type ProviderId,
  type Tier,
  type UserProfile,
} from "@/types";

const BASE_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:3000";
const ACCESS_KEY = "blu.accessToken";
const REFRESH_KEY = "blu.refreshToken";

export const sessionStorage = {
  get accessToken(): string | null {
    if (typeof window === "undefined") return null;
    return window.localStorage.getItem(ACCESS_KEY);
  },
  get refreshToken(): string | null {
    if (typeof window === "undefined") return null;
    return window.localStorage.getItem(REFRESH_KEY);
  },
  setTokens(accessToken: string, refreshToken: string) {
    window.localStorage.setItem(ACCESS_KEY, accessToken);
    window.localStorage.setItem(REFRESH_KEY, refreshToken);
  },
  clear() {
    window.localStorage.removeItem(ACCESS_KEY);
    window.localStorage.removeItem(REFRESH_KEY);
  },
};

async function parseError(response: Response): Promise<ApiError> {
  let message = `Error del servidor (${response.status})`;
  let code: string | undefined;
  try {
    const body = (await response.json()) as { code?: string; message?: string | string[]; error?: string };
    if (typeof body.message === "string") message = body.message;
    else if (body.error) message = body.error;
    if (body.code) code = body.code;
  } catch {
    // sin cuerpo JSON
  }
  return new ApiError(message, response.status, code);
}

async function rawFetch(path: string, init: RequestInit = {}, attempt = 0): Promise<Response> {
  const headers = new Headers(init.headers);
  headers.set("Content-Type", "application/json");
  const token = sessionStorage.accessToken;
  if (token) headers.set("Authorization", `Bearer ${token}`);

  const response = await fetch(`${BASE_URL}${path}`, { ...init, headers });

  if (response.status === 401 && attempt === 0) {
    const refreshed = await tryRefresh();
    if (refreshed) return rawFetch(path, init, attempt + 1);
  }
  return response;
}

async function tryRefresh(): Promise<boolean> {
  const refreshToken = sessionStorage.refreshToken;
  if (!refreshToken) return false;
  try {
    const response = await fetch(`${BASE_URL}/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken }),
    });
    if (!response.ok) {
      sessionStorage.clear();
      return false;
    }
    const data = (await response.json()) as AuthResult;
    sessionStorage.setTokens(data.accessToken, data.refreshToken);
    return true;
  } catch {
    sessionStorage.clear();
    return false;
  }
}

async function request<T>(path: string, init: RequestInit = {}): Promise<T> {
  const response = await rawFetch(path, init);
  if (!response.ok) throw await parseError(response);
  if (response.status === 204) return undefined as T;
  return (await response.json()) as T;
}

const json = (method: string) => (body?: unknown): RequestInit => ({
  method,
  body: body === undefined ? undefined : JSON.stringify(body),
});

export const authApi = {
  login: (email: string, password: string) => request<AuthResult>("/auth/login", json("POST")({ email, password })),
  register: (email: string, password: string, displayName: string) =>
    request<AuthResult>("/auth/register", json("POST")({ email, password, displayName })),
  me: () => request<UserProfile>("/auth/me"),
  logout: (refreshToken: string) => request<{ ok: boolean }>("/auth/logout", json("POST")({ refreshToken })),
};

export const projectsApi = {
  list: () => request<ProjectSummary[]>("/projects"),
  create: (name: string) => request<ProjectSummary>("/projects", json("POST")({ name })),
  get: (id: string) => request<ProjectSummary>(`/projects/${id}`),
  update: (id: string, name: string) => request<ProjectSummary>(`/projects/${id}`, json("PATCH")({ name })),
  remove: (id: string) => request<void>(`/projects/${id}`, json("DELETE")()),
  members: (id: string) => request<ProjectMember[]>(`/projects/${id}/members`),
  addMember: (id: string, userId: string, role: MemberRole) =>
    request<void>(`/projects/${id}/members`, json("POST")({ userId, role })),
  updateMemberRole: (id: string, userId: string, role: MemberRole) =>
    request<void>(`/projects/${id}/members/${userId}`, json("PATCH")({ role })),
  removeMember: (id: string, userId: string) => request<void>(`/projects/${id}/members/${userId}`, json("DELETE")()),
};

export const chatApi = {
  send: (body: { text: string; tier?: Tier; projectId?: string; agentId?: AgentId; history?: ChatMessage[] }) =>
    request<ChatResponse>("/chat", json("POST")(body)),
  sessions: (projectId?: string) =>
    request<ChatSession[]>(`/chat/sessions${projectId ? `?projectId=${encodeURIComponent(projectId)}` : ""}`),
  createSession: (body: { projectId?: string; agentId?: AgentId; title?: string }) =>
    request<ChatSession>("/chat/sessions", json("POST")(body)),
  session: (id: string) => request<ChatSession>(`/chat/sessions/${id}`),
};

export const vaultApi = {
  notes: (projectId: string) => request<NoteSummary[]>(`/vault/notes?projectId=${encodeURIComponent(projectId)}`),
  createNote: (body: { projectId: string; title: string; bodyMd?: string; tags?: string[] }) =>
    request<NoteSummary>("/vault/notes", json("POST")(body)),
  getNote: (id: string) => request<NoteSummary>(`/vault/notes/${id}`),
  updateNote: (id: string, body: { title?: string; bodyMd?: string; tags?: string[] }) =>
    request<NoteSummary>(`/vault/notes/${id}`, json("PATCH")(body)),
  removeNote: (id: string) => request<void>(`/vault/notes/${id}`, json("DELETE")()),
  search: (projectId: string, q: string, limit = 10) =>
    request<NoteSummary[]>(`/vault/search?projectId=${encodeURIComponent(projectId)}&q=${encodeURIComponent(q)}&limit=${limit}`),
};

export const userApi = {
  profile: () => request<UserProfile>("/user/profile"),
  updateProfile: (body: { displayName?: string; timezone?: string }) =>
    request<UserProfile>("/user/profile", json("PATCH")(body)),
  apiKeys: () => request<ApiKeyMasked[]>("/user/api-keys"),
  addApiKey: (provider: ProviderId, key: string) => request<ApiKeyMasked>("/user/api-keys", json("POST")({ provider, key })),
  removeApiKey: (provider: ProviderId) => request<void>(`/user/api-keys/${provider}`, json("DELETE")()),
  credits: () => request<CreditBalance>("/user/credits"),
};