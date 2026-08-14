// Chat con agentes de BLU: historial en memoria, sesiones persistidas opcionales.

"use client";

import { Suspense, useCallback, useEffect, useRef, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Button } from "@/components/Button";
import { Card } from "@/components/Card";
import { MainLayout } from "@/components/MainLayout";
import { chatApi, projectsApi } from "@/lib/api";
import { cn } from "@/lib/utils";
import type { AgentId, ChatMessage, ChatSession, ProjectSummary, Tier } from "@/types";

const AGENTS: Array<{ id: AgentId; label: string }> = [
  { id: "plan", label: "Planificador" },
  { id: "build", label: "Constructor" },
  { id: "cowork", label: "Colaborador" },
  { id: "research", label: "Investigador" },
  { id: "qa", label: "QA" },
  { id: "automation", label: "Automatización" },
  { id: "knowledge", label: "Conocimiento" },
];

const TIERS: Array<{ id: Tier; label: string }> = [
  { id: "light", label: "Rápido" },
  { id: "flash", label: "Flash" },
  { id: "ultra", label: "Ultra" },
  { id: "auto", label: "Auto" },
];

export default function ChatPage() {
  return (
    <Suspense fallback={null}>
      <ChatPageInner />
    </Suspense>
  );
}

function ChatPageInner() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const sessionId = searchParams.get("session");

  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState("");
  const [agent, setAgent] = useState<AgentId>("cowork");
  const [tier, setTier] = useState<Tier>("auto");
  const [projectId, setProjectId] = useState<string | undefined>();
  const [projects, setProjects] = useState<ProjectSummary[]>([]);
  const [session, setSession] = useState<ChatSession | null>(null);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    void projectsApi
      .list()
      .then(setProjects)
      .catch(() => setProjects([]));
  }, []);

  useEffect(() => {
    if (sessionId) {
      void chatApi
        .session(sessionId)
        .then(setSession)
        .catch(() => setSession(null));
    }
  }, [sessionId]);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const send = useCallback(
    async (e: React.FormEvent) => {
      e.preventDefault();
      const text = input.trim();
      if (!text || sending) return;

      const history = messages.filter((m) => m.role === "user" || m.role === "assistant");
      const userMessage: ChatMessage = { role: "user", content: text };
      setMessages((prev) => [...prev, userMessage]);
      setInput("");
      setSending(true);
      setError(null);

      try {
        const response = await chatApi.send({
          text,
          tier,
          agentId: agent,
          projectId,
          history,
        });
        const assistantMessage: ChatMessage = { role: "assistant", content: response.text };
        setMessages((prev) => [...prev, assistantMessage]);
        if (!session) {
          const created = await chatApi.createSession({
            projectId,
            agentId: agent,
            title: text.slice(0, 60),
          });
          setSession(created);
          router.replace(`/chat?session=${created.id}`);
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : "No se pudo enviar el mensaje.");
      } finally {
        setSending(false);
      }
    },
    [input, sending, tier, agent, projectId, messages, session, router],
  );

  return (
    <MainLayout>
      <div className="mx-auto flex h-[calc(100vh-6rem)] max-w-4xl flex-col">
        <header className="mb-4 flex flex-wrap items-center justify-between gap-3">
          <div>
            <h1 className="text-xl font-bold text-slate-900 dark:text-slate-100">Chat con BLU</h1>
            <p className="text-sm text-slate-500 dark:text-slate-400">
              {session ? session.title : "Nueva conversación"}
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <select
              value={agent}
              onChange={(e) => setAgent(e.target.value as AgentId)}
              className="h-9 rounded-lg border border-slate-300 bg-white px-2 text-sm dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100"
            >
              {AGENTS.map((a) => (
                <option key={a.id} value={a.id}>
                  {a.label}
                </option>
              ))}
            </select>
            <select
              value={tier}
              onChange={(e) => setTier(e.target.value as Tier)}
              className="h-9 rounded-lg border border-slate-300 bg-white px-2 text-sm dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100"
            >
              {TIERS.map((t) => (
                <option key={t.id} value={t.id}>
                  {t.label}
                </option>
              ))}
            </select>
            {projects.length > 0 && (
              <select
                value={projectId ?? ""}
                onChange={(e) => setProjectId(e.target.value || undefined)}
                className="h-9 rounded-lg border border-slate-300 bg-white px-2 text-sm dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100"
              >
                <option value="">Sin proyecto</option>
                {projects.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.name}
                  </option>
                ))}
              </select>
            )}
          </div>
        </header>

        <Card className="flex min-h-0 flex-1 flex-col p-0">
          <div className="flex-1 space-y-4 overflow-y-auto p-5">
            {messages.length === 0 && (
              <div className="flex h-full items-center justify-center">
                <p className="text-center text-sm text-slate-500 dark:text-slate-400">
                  Pregúntale a BLU sobre tu proyecto, notas o lo que necesites.
                </p>
              </div>
            )}
            {messages.map((message, i) => (
              <div key={i} className={cn("flex", message.role === "user" ? "justify-end" : "justify-start")}>
                <div
                  className={cn(
                    "max-w-[80%] whitespace-pre-wrap rounded-2xl px-4 py-2.5 text-sm",
                    message.role === "user"
                      ? "rounded-br-sm bg-indigo-600 text-white"
                      : "rounded-bl-sm bg-slate-100 text-slate-900 dark:bg-slate-800 dark:text-slate-100",
                  )}
                >
                  {message.content}
                </div>
              </div>
            ))}
            {sending && (
              <div className="flex justify-start">
                <div className="rounded-2xl rounded-bl-sm bg-slate-100 px-4 py-2.5 text-sm text-slate-500 dark:bg-slate-800 dark:text-slate-400">
                  BLU está pensando…
                </div>
              </div>
            )}
            <div ref={bottomRef} />
          </div>

          {error && (
            <p className="border-t border-slate-200 px-5 py-2 text-sm text-red-600 dark:border-slate-800 dark:text-red-400">
              {error}
            </p>
          )}

          <form onSubmit={send} className="flex gap-2 border-t border-slate-200 p-4 dark:border-slate-800">
            <input
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="Escribe un mensaje…"
              className="flex-1 rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 placeholder:text-slate-400 focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/30 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100"
              maxLength={30000}
            />
            <Button type="submit" disabled={sending || !input.trim()}>
              Enviar
            </Button>
          </form>
        </Card>
      </div>
    </MainLayout>
  );
}