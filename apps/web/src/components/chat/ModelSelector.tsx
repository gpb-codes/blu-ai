// Selector de modelo del diseño: pill "Blu Light" + dropdown con OTROS MODELOS
// (BYOK) y SOYBLUIA (tiers). Botón circular de enviar.

"use client";

import { cn } from "@/lib/utils";
import type { Tier } from "@/types";

export const BLU_MODELS: Array<{ label: string; tier: Tier }> = [
  { label: "Blu Light", tier: "light" },
  { label: "Blu Flash", tier: "flash" },
  { label: "Blu Ultra", tier: "ultra" },
];

const OTHER_MODELS = [
  { name: "Claude", tier: "auto" as Tier, color: "#FB923C", icon: "◈" },
  { name: "ChatGPT", tier: "auto" as Tier, color: "#34D399", icon: "◉" },
  { name: "Gemini", tier: "auto" as Tier, color: "#60A5FA", icon: "✦" },
];

export function modelToTier(model: string): Tier {
  return BLU_MODELS.find((m) => m.label === model)?.tier ?? "auto";
}

export function ModelPill({ label, onToggle }: { label: string; onToggle: () => void }) {
  return (
    <button
      type="button"
      onClick={onToggle}
      className="flex shrink-0 items-center gap-0.5 rounded-full border border-blu-outline/30 bg-blu-surface-highest px-3 py-1.5 text-[13px] text-blu-on transition-colors hover:bg-blu-surface"
    >
      {label}
      <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden>
        <path strokeLinecap="round" strokeLinejoin="round" d="m6 9 6 6 6-6" />
      </svg>
    </button>
  );
}

export function ModelDropdown({
  selected,
  onSelected,
  onClose,
}: {
  selected: string;
  onSelected: (model: string) => void;
  onClose: () => void;
}) {
  return (
    <div className="absolute right-2 top-full z-20 mt-2 w-64 rounded-xl border border-blu-outline/30 bg-blu-surface-low shadow-2xl">
      <div className="p-3 pb-1">
        <p className="px-2 py-1 text-[10px] font-medium uppercase tracking-wider text-blu-on-variant">Otros modelos</p>
        {OTHER_MODELS.map((m) => (
          <DropdownRow key={m.name} onSelect={() => onSelected(m.name)}>
            <span className="w-4 text-center text-sm" style={{ color: m.color }}>
              {m.icon}
            </span>
            <span className="text-sm text-blu-on">{m.name}</span>
          </DropdownRow>
        ))}
      </div>
      <div className="h-px bg-blu-outline/30" />
      <div className="p-3 pt-2">
        <p className="px-2 py-1 text-[10px] font-medium uppercase tracking-wider text-blu-on-variant">Soybluia</p>
        {BLU_MODELS.map((m) => (
          <DropdownRow key={m.label} onSelect={() => onSelected(m.label)} selected={selected === m.label}>
            <span className={cn("flex-1 text-sm", selected === m.label ? "text-white" : "text-blu-on-variant")}>{m.label}</span>
            {selected === m.label && <span className="text-white">✓</span>}
          </DropdownRow>
        ))}
      </div>
      <div className="h-2" />
      <button
        type="button"
        onClick={onClose}
        className="absolute -top-2 right-0 flex h-6 w-6 items-center justify-center rounded-full bg-blu-surface-high text-xs text-blu-on-variant"
        aria-label="Cerrar"
      >
        ✕
      </button>
    </div>
  );
}

function DropdownRow({
  children,
  onSelect,
  selected = false,
}: {
  children: React.ReactNode;
  onSelect: () => void;
  selected?: boolean;
}) {
  return (
    <button
      type="button"
      onClick={onSelect}
      className={cn(
        "flex w-full items-center gap-3 rounded-lg px-2 py-2 transition-colors hover:bg-blu-surface-high",
        selected && "bg-blu-primary-soft hover:bg-blu-primary-soft",
      )}
    >
      {children}
    </button>
  );
}

export function ChatSendButton({ onSend, disabled }: { onSend: () => void; disabled?: boolean }) {
  return (
    <button
      type="button"
      onClick={onSend}
      disabled={disabled}
      aria-label="Enviar"
      className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-blu-primary-solid text-white shadow-[0_2px_4px_rgba(10,52,245,0.3)] transition-opacity disabled:opacity-40"
    >
      <svg viewBox="0 0 24 24" className="h-[18px] w-[18px]" fill="none" stroke="currentColor" strokeWidth="2.2" aria-hidden>
        <path strokeLinecap="round" strokeLinejoin="round" d="M12 19V5m-7 7 7-7 7 7" />
      </svg>
    </button>
  );
}