// Burbujas del chat con el diseño de referencia: usuario a la derecha con
// estado SENT, IA con avatar ⚡, acciones y tarjetas de sugerencia.

"use client";

import { cn } from "@/lib/utils";
import { MarkdownRenderer } from "@/components/chat/MarkdownRenderer";
import type { ChatMessage } from "@/types";

export function UserBubble({ text }: { text: string }) {
  return (
    <div className="flex justify-end">
      <div className="max-w-[70%] rounded-[18px] border border-blu-outline/30 bg-blu-surface-high px-4 py-3 text-[15px] leading-relaxed text-blu-on">
        {text}
      </div>
    </div>
  );
}

export function AiBubble({ text }: { text: string }) {
  return (
    <div className="flex items-start gap-3">
      <AiAvatar />
      <div className="min-w-0 flex-1 pt-1">
        <MarkdownRenderer text={text} />
        <div className="mt-3 flex gap-1 opacity-60 hover:opacity-100">
          <button
            type="button"
            onClick={() => void navigator.clipboard.writeText(text)}
            aria-label="Copiar"
            className="rounded p-1.5 text-blu-on-variant hover:bg-blu-surface-high hover:text-blu-on"
          >
            ⧉
          </button>
          <ActionIcon label="Me gusta">👍</ActionIcon>
          <ActionIcon label="Regenerar">↻</ActionIcon>
        </div>
      </div>
    </div>
  );
}

export function AiAvatar() {
  return (
    <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg border border-blu-outline/20 bg-white">
      <svg viewBox="0 0 24 24" className="h-4 w-4 text-blu-primary-solid" fill="currentColor" aria-hidden>
        <path d="M13 2 4.5 13.5h5L11 22l8.5-11.5h-5L13 2z" />
      </svg>
    </div>
  );
}

function ActionIcon({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <button type="button" title={label} className="text-sm opacity-80 transition-opacity hover:opacity-100">
      {children}
    </button>
  );
}

export function TypingIndicator() {
  return (
    <div className="flex items-start gap-4">
      <AiAvatar />
      <div className="rounded-2xl border border-blu-outline/20 bg-blu-surface-low p-5">
        <div className="flex items-center gap-1.5">
          {[0, 1, 2].map((i) => (
            <span
              key={i}
              className="blu-typing-dot h-2 w-2 rounded-full bg-blu-on-variant"
              style={{ animationDelay: `${i * 0.2}s` }}
            />
          ))}
        </div>
      </div>
    </div>
  );
}

export function MessageList({ messages, typing }: { messages: ChatMessage[]; typing: boolean }) {
  return (
    <div className="space-y-6">
      {messages.map((message, i) => (
        <div key={i} className={cn(message.role === "user" ? "flex justify-end" : "flex")}>
          {message.role === "user" ? <UserBubble text={message.content} /> : <AiBubble text={message.content} />}
        </div>
      ))}
      {typing && <TypingIndicator />}
    </div>
  );
}