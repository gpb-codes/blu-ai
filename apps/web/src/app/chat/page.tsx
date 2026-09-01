// Chat con el diseño soybluia: landing "¿En qué trabajamos hoy?", burbujas con
// estado SENT, selector de modelo (Blu Light/Flash/Ultra + otros modelos) y
// sesiones persistentes vinculadas a proyectos.

"use client";

import { Suspense, useCallback, useEffect, useRef, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { BottomInputArea } from "@/components/chat/BottomInputArea";
import { MessageList } from "@/components/chat/Bubbles";
import { LandingCard } from "@/components/chat/LandingCard";
import { BLU_MODELS, modelToTier } from "@/components/chat/ModelSelector";
import { MainLayout } from "@/components/MainLayout";
import { chatApi, projectsApi } from "@/lib/api";
import type { AgentId, ChatMessage, ChatSession, ProjectSummary } from "@/types";

const AGENTS: Array<{ id: AgentId; label: string }> = [
  { id: "cowork", label: "Colaborador" },
  { id: "plan", label: "Planificador" },
  { id: "build", label: "Constructor" },
  { id: "research", label: "Investigador" },
  { id: "qa", label: "QA" },
  { id: "automation", label: "Automatización" },
  { id: "knowledge", label: "Conocimiento" },
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
  const [model, setModel] = useState(BLU_MODELS[0].label);
  const [agent, setAgent] = useState<AgentId>("cowork");
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
  }, [messages, sending]);

  const send = useCallback(async () => {
    const text = input.trim();
    if (!text || sending) return;

    const history = messages.filter((m) => m.role === "user" || m.role === "assistant");
    setMessages((prev) => [...prev, { role: "user", content: text }]);
    setInput("");
    setSending(true);
    setError(null);

    try {
      const response = await chatApi.send({ text, tier: modelToTier(model), agentId: agent, projectId, history });
      setMessages((prev) => [...prev, { role: "assistant", content: response.text }]);
      if (!session) {
        const created = await chatApi.createSession({ projectId, agentId: agent, title: text.slice(0, 60) });
        setSession(created);
        router.replace(`/chat?session=${created.id}`);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "No se pudo enviar el mensaje.");
    } finally {
      setSending(false);
    }
  }, [input, sending, model, agent, projectId, messages, session, router]);

  return (
    <MainLayout>
      <div className="flex h-[calc(100vh-0px)] flex-col">
        <div className="flex flex-wrap items-center justify-between gap-3 border-b border-blu-outline/20 px-6 py-3">
          <p className="text-sm text-blu-on-variant">
            {session ? session.title : "Nueva conversación"}
          </p>
          <select
            value={agent}
            onChange={(e) => setAgent(e.target.value as AgentId)}
            className="h-8 rounded-lg border border-blu-outline/40 bg-blu-surface-low px-2 text-xs text-blu-on focus:outline-none focus:ring-1 focus:ring-blu-primary/40"
          >
            {AGENTS.map((a) => (
              <option key={a.id} value={a.id}>
                {a.label}
              </option>
            ))}
          </select>
        </div>

        <div className="flex-1 overflow-y-auto px-4 py-8">
          {messages.length === 0 ? (
            <div className="flex min-h-full items-center justify-center">
              <LandingCard
                input={input}
                setInput={setInput}
                model={model}
                onModelSelected={(m) => setModel(m)}
                projects={projects}
                projectId={projectId}
                onProjectSelected={setProjectId}
                onSend={() => void send()}
                sending={sending}
              />
            </div>
          ) : (
            <div className="mx-auto max-w-4xl">
              <MessageList messages={messages} typing={sending} />
              <div ref={bottomRef} />
            </div>
          )}
        </div>

        {error && (
          <p className="border-t border-blu-outline/20 px-6 py-2 text-sm text-blu-error">{error}</p>
        )}

        {messages.length > 0 && (
          <BottomInputArea
            input={input}
            setInput={setInput}
            model={model}
            onModelSelected={(m) => setModel(m)}
            onSend={() => void send()}
            sending={sending}
          />
        )}
      </div>
    </MainLayout>
  );
}