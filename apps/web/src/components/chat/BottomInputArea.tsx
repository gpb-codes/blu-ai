// Barra de input fija (con mensajes): caja redondeada con adjuntar, input,
// selector de modelo, micrófono y botón de enviar.

"use client";

import { useRef, useState } from "react";
import { ChatSendButton, ModelDropdown, ModelPill } from "@/components/chat/ModelSelector";

export function BottomInputArea({
  input,
  setInput,
  model,
  onModelSelected,
  onSend,
  sending,
}: {
  input: string;
  setInput: (value: string) => void;
  model: string;
  onModelSelected: (model: string) => void;
  onSend: () => void;
  sending: boolean;
}) {
  const [modelOpen, setModelOpen] = useState(false);
  const textareaRef = useRef<HTMLTextAreaElement | null>(null);

  const submit = () => {
    setModelOpen(false);
    onSend();
  };

  return (
    <div className="border-t border-blu-outline/20 bg-blu-bg px-4 py-3">
      <div className="relative mx-auto max-w-4xl">
        <div className="flex items-end gap-1 rounded-xl border border-blu-outline/20 bg-blu-surface-low p-2">
          <button type="button" aria-label="Adjuntar" className="px-1 py-1 text-blu-on-variant">
            <svg viewBox="0 0 24 24" className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 5v14M5 12h14" />
            </svg>
          </button>
          <textarea
            ref={textareaRef}
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault();
                submit();
              }
            }}
            placeholder="Ask soybluia..."
            rows={1}
            onInput={() => {
              const el = textareaRef.current;
              if (!el) return;
              el.style.height = "auto";
              el.style.height = `${Math.min(el.scrollHeight, 132)}px`;
            }}
            className="max-h-[132px] min-h-[40px] flex-1 resize-none bg-transparent px-2 py-2.5 text-[15px] text-blu-on placeholder:text-blu-on-variant focus:outline-none"
          />
          <div className="hidden items-center gap-1 md:flex">
            <button
              type="button"
              aria-label="Memoria"
              title="Mencionar memoria @"
              onClick={() => setInput(`${input}@`)}
              className="rounded px-1.5 py-1 text-xs font-medium text-blu-on-variant hover:bg-blu-surface-high hover:text-blu-on"
            >
              @
            </button>
            <button
              type="button"
              aria-label="Comandos"
              title="Comandos /"
              onClick={() => setInput(`${input}/`)}
              className="rounded px-1.5 py-1 text-xs font-medium text-blu-on-variant hover:bg-blu-surface-high hover:text-blu-on"
            >
              /
            </button>
            <button
              type="button"
              aria-label="Herramientas"
              title="Herramientas (próximamente)"
              onClick={() => alert("Tools — Próximamente")}
              className="rounded px-1.5 py-1 text-xs text-blu-on-variant hover:bg-blu-surface-high"
            >
              Tools
            </button>
          </div>
          <div className="relative shrink-0">
            <ModelPill label={model} onToggle={() => setModelOpen((v) => !v)} />
            {modelOpen && <ModelDropdown selected={model} onSelected={onModelSelected} onClose={() => setModelOpen(false)} />}
          </div>
          <button type="button" aria-label="Microfono" className="hidden px-1 py-1 text-blu-on-variant md:block">
            <svg viewBox="0 0 24 24" className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 15a3 3 0 0 0 3-3V7a3 3 0 1 0-6 0v5a3 3 0 0 0 3 3Zm-5-3a5 5 0 0 0 10 0m-5 5v3m-3 0h6" />
            </svg>
          </button>
          <ChatSendButton onSend={submit} disabled={sending || !input.trim()} />
        </div>
      </div>
    </div>
  );
}