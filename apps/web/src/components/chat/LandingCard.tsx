// Estado vacío del chat del diseño: "¿En qué trabajamos hoy?" + tarjeta con
// "Agregar a un proyecto", input, selector de modelo y botón de enviar.

"use client";

import { useRef, useState } from "react";
import { ChatSendButton, ModelDropdown, ModelPill } from "@/components/chat/ModelSelector";
import { cn } from "@/lib/utils";
import type { ProjectSummary } from "@/types";

export function LandingCard({
  input,
  setInput,
  model,
  onModelSelected,
  projects,
  projectId,
  onProjectSelected,
  onSend,
  sending,
}: {
  input: string;
  setInput: (value: string) => void;
  model: string;
  onModelSelected: (model: string) => void;
  projects: ProjectSummary[];
  projectId?: string;
  onProjectSelected: (projectId?: string) => void;
  onSend: () => void;
  sending: boolean;
}) {
  const [modelOpen, setModelOpen] = useState(false);
  const [projectOpen, setProjectOpen] = useState(false);
  const textareaRef = useRef<HTMLTextAreaElement | null>(null);

  const submit = () => {
    setModelOpen(false);
    setProjectOpen(false);
    onSend();
  };

  return (
    <div className="flex flex-col items-center px-4">
      <h1 className="text-center font-geist text-2xl font-semibold text-blu-on md:text-[32px] md:leading-[1.2]">
        ¿En qué trabajamos hoy?
      </h1>

      <div className="relative mt-10 w-full max-w-[672px]">
        <div className="overflow-hidden rounded-xl border border-blu-outline/30 bg-blu-surface-low shadow-2xl">
          <div className="relative">
            <button
              type="button"
              onClick={() => setProjectOpen((v) => !v)}
              className="flex w-full items-center gap-3 px-5 py-4 text-left transition-colors hover:bg-blu-surface-high"
            >
              <svg viewBox="0 0 24 24" className="h-5 w-5 text-blu-on-variant" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden>
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m-8-8h16" />
              </svg>
              <span className="text-sm text-blu-on-variant">{projectId ? "Cambiar de proyecto" : "Agregar a un proyecto"}</span>
            </button>

            {projectOpen && (
              <div className="absolute left-3 right-3 top-full z-20 mt-2 overflow-hidden rounded-xl border border-blu-outline/30 bg-blu-surface shadow-2xl">
                <button
                  type="button"
                  onClick={() => {
                    onProjectSelected(undefined);
                    setProjectOpen(false);
                  }}
                  className={cn(
                    "w-full px-4 py-2.5 text-left text-sm hover:bg-blu-surface-high",
                    !projectId ? "bg-blu-primary-soft text-white" : "text-blu-on-variant",
                  )}
                >
                  Sin proyecto
                </button>
                {projects.map((p) => (
                  <button
                    key={p.id}
                    type="button"
                    onClick={() => {
                      onProjectSelected(p.id);
                      setProjectOpen(false);
                    }}
                    className={cn(
                      "w-full px-4 py-2.5 text-left text-sm hover:bg-blu-surface-high",
                      projectId === p.id ? "bg-blu-primary-soft text-white" : "text-blu-on-variant",
                    )}
                  >
                    {p.name}
                  </button>
                ))}
              </div>
            )}
          </div>

          <div className="h-px bg-blu-outline/30" />

          <div className="flex items-end gap-2 bg-blu-surface px-5 pb-3 pt-2">
            <button type="button" aria-label="Adjuntar" className="mb-2 text-blu-on-variant">
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
              placeholder="Pregunta lo que quieras"
              rows={1}
              onInput={() => {
                const el = textareaRef.current;
                if (!el) return;
                el.style.height = "auto";
                el.style.height = `${Math.min(el.scrollHeight, 132)}px`;
              }}
              className="max-h-[132px] min-h-[40px] flex-1 resize-none bg-transparent py-2 text-[15px] text-blu-on placeholder:text-blu-on-variant focus:outline-none"
            />
            <div className="relative">
              <ModelPill label={model} onToggle={() => setModelOpen((v) => !v)} />
              {modelOpen && (
                <ModelDropdown selected={model} onSelected={onModelSelected} onClose={() => setModelOpen(false)} />
              )}
            </div>
            <ChatSendButton onSend={submit} disabled={sending || !input.trim()} />
          </div>
        </div>
      </div>
    </div>
  );
}