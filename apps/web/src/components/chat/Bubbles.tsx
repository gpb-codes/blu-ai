// Burbujas del chat con el diseño de referencia: usuario a la derecha con
// estado SENT, IA con avatar ⚡, acciones y tarjetas de sugerencia.

"use client";

import { cn } from "@/lib/utils";
import { MarkdownRenderer } from "@/components/chat/MarkdownRenderer";
import type { ChatMessage, MessageBlock } from "@/types";

export function UserBubble({ text }: { text: string }) {
  return (
    <div className="flex justify-end">
      <div className="max-w-[70%] rounded-[18px] border border-blu-outline/30 bg-blu-surface-high px-4 py-3 text-[15px] leading-relaxed text-blu-on">
        {text}
      </div>
    </div>
  );
}

export function AiBubble({ text, blocks }: { text: string; blocks?: MessageBlock[] }) {
  const hasBlocks = blocks && blocks.length > 0;
  return (
    <div className="flex items-start gap-3">
      <AiAvatar />
      <div className="min-w-0 flex-1 pt-1">
        {hasBlocks ? (
          <div className="space-y-3">
            {blocks!.map((b, i) => {
              if (b.type === "code" && "code" in b) return <CodePreview key={i} code={(b as { code: string }).code} lang={(b as { lang?: string }).lang} />;
              if (b.type === "image" && "url" in b) return <img key={i} src={(b as { url: string }).url} alt={(b as { alt?: string }).alt ?? ""} className="max-w-full rounded-lg border border-blu-outline/20" />;
              if (b.type === "artifact" && "html" in b) return <ArtifactPreview key={i} html={(b as { html?: string }).html ?? ""} title={(b as { title: string }).title} />;
              const t = (b as { text?: string }).text ?? text;
              return <MarkdownRenderer key={i} text={t} />;
            })}
          </div>
        ) : (
          <MarkdownRenderer text={text} />
        )}
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

function CodePreview({ code, lang }: { code: string; lang?: string }) {
  return (
    <div className="overflow-hidden rounded-lg border border-blu-outline/20 bg-blu-surface-low">
      <div className="flex items-center justify-between border-b border-blu-outline/10 bg-blu-surface px-3 py-1.5">
        <span className="font-mono text-xs text-blu-on-variant">{lang || "code"}</span>
        <button type="button" onClick={() => void navigator.clipboard.writeText(code)} className="text-xs text-blu-on-variant hover:text-blu-on">Copiar</button>
      </div>
      <pre className="overflow-x-auto p-3 font-mono text-sm text-blu-on"><code>{code}</code></pre>
    </div>
  );
}

function ArtifactPreview({ html, title }: { html: string; title: string }) {
  return (
    <div className="overflow-hidden rounded-xl border border-blu-outline/20 bg-white">
      <div className="flex items-center justify-between border-b bg-blu-surface-low px-3 py-2">
        <span className="text-sm font-medium text-blu-on">{title}</span>
        <span className="text-xs text-blu-on-variant">Preview</span>
      </div>
      <div className="p-3">
        <div dangerouslySetInnerHTML={{ __html: html }} />
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
        <div key={message.id ?? i} className={cn(message.role === "user" ? "flex justify-end" : "flex")}>
          {message.role === "user" ? <UserBubble text={message.content} /> : <AiBubble text={message.content} blocks={message.blocks} />}
        </div>
      ))}
      {typing && <TypingIndicator />}
    </div>
  );
}