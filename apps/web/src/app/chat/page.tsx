"use client";

import { Suspense, useCallback, useEffect, useRef, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { BottomInputArea } from "@/components/chat/BottomInputArea";
import { MessageList } from "@/components/chat/Bubbles";
import { LandingCard } from "@/components/chat/LandingCard";
import { BLU_MODELS, modelToTier } from "@/components/chat/ModelSelector";
import { AppShell } from "@/components/shell/AppShell";
import { ChatHeader } from "@/components/shell/ChatHeader";
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
    void projectsApi.list().then(setProjects).catch(() => setProjects([]));
  }, []);

  useEffect(() => {
    if (sessionId) {
      void chatApi.session(sessionId).then(setSession).catch(() => setSession(null));
    } else {
      setSession(null);
      setMessages([]);
    }
  }, [sessionId]);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, sending]);

  const send = useCallback(async () => {
    const text = input.trim();
    if (!text || sending) return;
    const history = messages.filter((m) => m.role === "user" || m.role === "assistant");
    const userMsg: ChatMessage = { id: `u-${Date.now()}`, role: "user", content: text, createdAt: new Date().toISOString() };
    setMessages((prev) => [...prev, userMsg]);
    setInput("");
    setSending(true);
    setError(null);
    try {
      const response = await chatApi.send({ text, tier: modelToTier(model), agentId: agent, projectId, history });
      const assistantMsg: ChatMessage = {
        id: `a-${Date.now()}`,
        role: "assistant",
        content: response.text,
        blocks: response.blocks,
        createdAt: new Date().toISOString(),
        metadata: { model: response.usage?.model, agentId: agent },
      };
      setMessages((prev) => [...prev, assistantMsg]);
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

  const isEmpty = messages.length === 0;

  return (
    <AppShell>
      <div className="flex h-screen flex-col">
        <ChatHeader
          title={session ? session.title : isEmpty ? "BLU IA" : "Nueva conversación"}
          onShare={
            session
              ? () => {
                  navigator.clipboard.writeText(`${window.location.origin}/chat?session=${session.id}`);
                }
              : undefined
          }
        />

        <div className="flex-1 overflow-y-auto">
          {isEmpty ? (
            <div className="flex min-h-full items-center justify-center px-4 py-12">
              <div className="w-full max-w-[720px]">
                <div className="mb-8 text-center">
                  <h1 className="font-geist text-[28px] font-semibold tracking-tight text-blu-on">¿En qué puedo ayudarte?</h1>
                  <p className="mt-2 text-sm text-blu-on-variant">Inicia una conversación o elige un proyecto para usar su memoria.</p>
                </div>
                <LandingCard
                  input={input}
                  setInput={setInput}
                  model={model}
                  onModelSelected={setModel}
                  projects={projects}
                  projectId={projectId}
                  onProjectSelected={setProjectId}
                  onSend={() => void send()}
                  sending={sending}
                />
              </div>
            </div>
          ) : (
            <div className="mx-auto max-w-[768px] px-4 py-8">
              <MessageList messages={messages} typing={sending} />
              <div ref={bottomRef} />
            </div>
          )}
        </div>

        {error && (
          <div className="border-t border-blu-outline/20 bg-blu-surface-low px-4 py-2 text-center text-sm text-blu-error">
            {error}
          </div>
        )}

        {!isEmpty && (
          <BottomInputArea
            input={input}
            setInput={setInput}
            model={model}
            onModelSelected={setModel}
            onSend={() => void send()}
            sending={sending}
          />
        )}
      </div>
    </AppShell>
  );
}
