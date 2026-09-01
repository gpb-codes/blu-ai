"use client";

import { useSidebar } from "@/components/shell/AppShell";

export function ChatHeader({
  title,
  onShare,
}: {
  title: string;
  onShare?: () => void;
}) {
  const { setOpen } = useSidebar();
  return (
    <header className="flex h-12 shrink-0 items-center justify-between border-b border-blu-outline/20 bg-blu-bg px-3">
      <div className="flex items-center gap-2">
        <button
          type="button"
          aria-label="Abrir menú"
          onClick={() => setOpen(true)}
          className="rounded p-2 text-blu-on-variant hover:bg-blu-surface-high hover:text-blu-on md:hidden"
        >
          <svg viewBox="0 0 24 24" className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth="2">
            <path strokeLinecap="round" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
        <h1 className="truncate text-sm font-medium text-blu-on">{title}</h1>
      </div>
      <div className="flex items-center gap-1">
        {onShare && (
          <button
            type="button"
            onClick={onShare}
            aria-label="Compartir"
            className="rounded p-2 text-blu-on-variant hover:bg-blu-surface-high hover:text-blu-on"
          >
            <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth="2">
              <path strokeLinecap="round" d="M8.5 12a3.5 3.5 0 1 0 3.5-3.5A3.5 3.5 0 0 0 8.5 12zM15.5 12a3.5 3.5 0 1 0 3.5-3.5A3.5 3.5 0 0 0 15.5 12zM12 8.5a3.5 3.5 0 1 0 0 7 3.5 3.5 0 0 0 0-7z" />
              <path strokeLinecap="round" d="M11 9l3 3-3 3" />
            </svg>
          </button>
        )}
      </div>
    </header>
  );
}
