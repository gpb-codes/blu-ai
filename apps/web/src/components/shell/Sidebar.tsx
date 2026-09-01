"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { chatApi } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import { cn } from "@/lib/utils";
import { useSidebar } from "@/components/shell/AppShell";
import type { ChatSession } from "@/types";

type Group = { label: string; items: ChatSession[] };

function groupByDate(sessions: ChatSession[]): Group[] {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const buckets: Record<string, ChatSession[]> = {
    Hoy: [],
    Ayer: [],
    "7 días": [],
    "30 días": [],
    Anteriores: [],
  };
  for (const s of sessions) {
    const d = new Date(s.updatedAt);
    const day = new Date(d.getFullYear(), d.getMonth(), d.getDate());
    const diff = Math.floor((today.getTime() - day.getTime()) / 86400000);
    if (diff <= 0) buckets["Hoy"].push(s);
    else if (diff === 1) buckets["Ayer"].push(s);
    else if (diff < 7) buckets["7 días"].push(s);
    else if (diff < 30) buckets["30 días"].push(s);
    else buckets["Anteriores"].push(s);
  }
  return Object.entries(buckets)
    .filter(([, items]) => items.length > 0)
    .map(([label, items]) => ({ label, items }));
}

function snippet(title: string) {
  return title.length > 48 ? `${title.slice(0, 45)}…` : title;
}

export function Sidebar({ mobile = false }: { mobile?: boolean }) {
  const pathname = usePathname();
  const router = useRouter();
  const { user, logout } = useAuth();
  const { collapsed, setCollapsed, setOpen } = useSidebar();
  const [sessions, setSessions] = useState<ChatSession[]>([]);
  const [query, setQuery] = useState("");
  const [menuId, setMenuId] = useState<string | null>(null);

  useEffect(() => {
    void chatApi
      .sessions()
      .then((s) => setSessions(s))
      .catch(() => setSessions([]));
  }, []);

  const filtered = useMemo(() => {
    if (!query.trim()) return sessions;
    const q = query.toLowerCase();
    return sessions.filter((s) => s.title.toLowerCase().includes(q));
  }, [sessions, query]);

  const groups = useMemo(() => groupByDate(filtered), [filtered]);
  const isCollapsed = collapsed && !mobile;

  const initials = (user?.displayName ?? "?")
    .split(" ")
    .map((w) => w[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();

  const handleNewChat = () => {
    router.push("/chat");
    setOpen(false);
  };

  if (isCollapsed) {
    return (
      <div className="flex h-full flex-col items-center border-r border-blu-outline/20 bg-blu-surface-low py-4">
        <button
          type="button"
          aria-label="Expandir"
          onClick={() => setCollapsed(false)}
          className="flex h-10 w-10 items-center justify-center rounded-lg bg-blu-primary-solid text-white"
        >
          <svg viewBox="0 0 24 24" className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth="2">
            <path strokeLinecap="round" d="M13 2 4.5 13.5h5L11 22l8.5-11.5h-5L13 2z" />
          </svg>
        </button>
        <button
          type="button"
          aria-label="Nuevo chat"
          onClick={handleNewChat}
          className="mt-4 flex h-10 w-10 items-center justify-center rounded-lg border border-blu-outline/20 bg-blu-surface text-blu-on hover:bg-blu-surface-high"
        >
          <svg viewBox="0 0 24 24" className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth="2">
            <path strokeLinecap="round" d="M12 5v14M5 12h14" />
          </svg>
        </button>
        <div className="mt-auto flex flex-col gap-2">
          <button
            type="button"
            aria-label="Perfil"
            onClick={() => router.push("/settings")}
            className="flex h-8 w-8 items-center justify-center rounded-full bg-blu-primary-solid text-xs font-bold text-white"
          >
            {initials}
          </button>
        </div>
      </div>
    );
  }

  return (
    <aside className="flex h-full flex-col border-r border-blu-outline/20 bg-blu-surface-low">
      {/* Header */}
      <div className="flex items-center gap-3 px-4 py-4">
        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blu-primary-solid">
          <svg viewBox="0 0 24 24" className="h-4 w-4 text-white" fill="currentColor" aria-hidden>
            <path d="M13 2 4.5 13.5h5L11 22l8.5-11.5h-5L13 2z" />
          </svg>
        </div>
        <span className="flex-1 text-sm font-semibold text-blu-on">BLU IA</span>
        <button
          type="button"
          aria-label={mobile ? "Cerrar" : "Colapsar"}
          onClick={() => (mobile ? setOpen(false) : setCollapsed(true))}
          className="rounded p-1 text-blu-on-variant hover:bg-blu-surface-high hover:text-blu-on"
        >
          <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth="2">
            <path strokeLinecap="round" d="M18 6L6 18M6 6l12 12" />
          </svg>
        </button>
      </div>

      {/* New chat */}
      <div className="px-3">
        <button
          type="button"
          onClick={handleNewChat}
          className="flex w-full items-center gap-2 rounded-lg border border-blu-outline/20 bg-blu-surface px-3 py-2.5 text-sm font-medium text-blu-on shadow-sm hover:bg-blu-surface-high"
        >
          <span className="flex h-6 w-6 items-center justify-center rounded bg-blu-primary-solid text-white">
            <svg viewBox="0 0 24 24" className="h-3.5 w-3.5" fill="none" stroke="currentColor" strokeWidth="2">
              <path strokeLinecap="round" d="M12 5v14M5 12h14" />
            </svg>
          </span>
          Nuevo chat
          <span className="ml-auto text-xs text-blu-on-variant">⌘ N</span>
        </button>
      </div>

      {/* Search */}
      <div className="px-3 py-3">
        <label htmlFor="blu-search" className="sr-only">
          Buscar conversaciones
        </label>
        <div className="relative">
          <svg
            viewBox="0 0 24 24"
            className="pointer-events-none absolute left-2.5 top-2.5 h-4 w-4 text-blu-on-variant"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
          >
            <path strokeLinecap="round" d="M21 21l-4.2-4.2M10.5 18a7.5 7.5 0 1 1 0-15 7.5 7.5 0 0 1 0 15z" />
          </svg>
          <input
            id="blu-search"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Buscar chats"
            className="h-9 w-full rounded-lg border border-blu-outline/20 bg-blu-surface py-2 pl-8 pr-3 text-sm text-blu-on placeholder:text-blu-on-variant focus:border-blu-primary-solid focus:outline-none focus:ring-1 focus:ring-blu-primary-solid/30"
          />
        </div>
      </div>

      {/* Conversations */}
      <div className="min-h-0 flex-1 overflow-y-auto px-2">
        {filtered.length === 0 ? (
          <p className="px-3 py-6 text-center text-sm text-blu-on-variant">
            {query ? "Sin resultados" : "Sin conversaciones"}
          </p>
        ) : (
          groups.map((g) => (
            <div key={g.label} className="mb-4">
              <p className="px-2 py-1 text-[11px] font-medium uppercase tracking-wider text-blu-on-variant/70">
                {g.label}
              </p>
              <div className="space-y-0.5">
                {g.items.map((s) => {
                  const active = pathname === `/chat` && typeof window !== "undefined" && window.location.search.includes(s.id);
                  return (
                    <div
                      key={s.id}
                      className={cn(
                        "group flex items-center gap-2 rounded-lg px-2 py-2 text-sm hover:bg-blu-surface-high",
                        active ? "bg-blu-surface-high text-blu-on" : "text-blu-on-variant",
                      )}
                    >
                      <Link
                        href={`/chat?session=${s.id}`}
                        onClick={() => setOpen(false)}
                        className="min-w-0 flex-1 truncate text-left"
                      >
                        <span className="block truncate">{snippet(s.title)}</span>
                      </Link>
                      <button
                        type="button"
                        aria-label="Más"
                        aria-haspopup="menu"
                        onClick={() => setMenuId(menuId === s.id ? null : s.id)}
                        className={cn(
                          "rounded p-1 hover:bg-blu-surface-highest hover:text-blu-on",
                          menuId === s.id ? "opacity-100" : "opacity-0 group-hover:opacity-100",
                        )}
                      >
                        <svg viewBox="0 0 24 24" className="h-4 w-4" fill="currentColor">
                          <circle cx="12" cy="12" r="2" />
                          <circle cx="19" cy="12" r="2" />
                          <circle cx="5" cy="12" r="2" />
                        </svg>
                      </button>
                      {menuId === s.id && (
                        <div className="absolute left-56 z-20 w-48 rounded-lg border border-blu-outline/20 bg-blu-surface p-1 shadow-xl">
                          <button
                            type="button"
                            onClick={() => {
                              navigator.clipboard.writeText(`${window.location.origin}/chat?session=${s.id}`);
                              setMenuId(null);
                            }}
                            className="w-full rounded px-3 py-2 text-left text-sm hover:bg-blu-surface-high"
                          >
                            Compartir
                          </button>
                          <button
                            type="button"
                            onClick={() => {
                              const name = prompt("Renombrar", s.title);
                              if (name) setMenuId(null);
                            }}
                            className="w-full rounded px-3 py-2 text-left text-sm hover:bg-blu-surface-high"
                          >
                            Renombrar
                          </button>
                          <button
                            type="button"
                            disabled
                            title="Próximamente"
                            className="w-full rounded px-3 py-2 text-left text-sm opacity-50"
                          >
                            Archivar
                          </button>
                          <button
                            type="button"
                            onClick={() => setMenuId(null)}
                            className="w-full rounded px-3 py-2 text-left text-sm text-red-400 hover:bg-red-500/10"
                          >
                            Eliminar
                          </button>
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          ))
        )}

        {/* Secondary nav — ChatGPT Projects/Memory/Agents/Artifacts/Library */}
        <div className="mt-6 space-y-0.5 border-t border-blu-outline/20 pt-4">
          <Link
            href="/projects"
            onClick={() => setOpen(false)}
            className={cn(
              "flex items-center gap-3 rounded-lg px-2 py-2 text-sm hover:bg-blu-surface-high",
              pathname.startsWith("/projects") ? "bg-blu-surface-high text-blu-on" : "text-blu-on-variant",
            )}
          >
            <span className="w-4 text-center">▤</span> Projects
          </Link>
          <Link
            href="/memory"
            onClick={() => setOpen(false)}
            className={cn(
              "flex items-center gap-3 rounded-lg px-2 py-2 text-sm hover:bg-blu-surface-high",
              pathname.startsWith("/memory") ? "bg-blu-surface-high text-blu-on" : "text-blu-on-variant",
            )}
          >
            <span className="w-4 text-center">🧠</span> Memory
          </Link>
          <Link
            href="/agents"
            onClick={() => setOpen(false)}
            className={cn(
              "flex items-center gap-3 rounded-lg px-2 py-2 text-sm hover:bg-blu-surface-high",
              pathname.startsWith("/agents") ? "bg-blu-surface-high text-blu-on" : "text-blu-on-variant",
            )}
          >
            <span className="w-4 text-center">🤖</span> Agents
          </Link>
          <Link
            href="/artifacts"
            onClick={() => setOpen(false)}
            className={cn(
              "flex items-center gap-3 rounded-lg px-2 py-2 text-sm hover:bg-blu-surface-high",
              pathname.startsWith("/artifacts") ? "bg-blu-surface-high text-blu-on" : "text-blu-on-variant",
            )}
          >
            <span className="w-4 text-center">⬢</span> Artifacts
          </Link>
          <Link
            href="/library"
            onClick={() => setOpen(false)}
            className={cn(
              "flex items-center gap-3 rounded-lg px-2 py-2 text-sm hover:bg-blu-surface-high",
              pathname.startsWith("/library") ? "bg-blu-surface-high text-blu-on" : "text-blu-on-variant",
            )}
          >
            <span className="w-4 text-center">📚</span> Library
          </Link>
          <Link
            href="/dashboard"
            onClick={() => setOpen(false)}
            className={cn(
              "flex items-center gap-3 rounded-lg px-2 py-2 text-sm hover:bg-blu-surface-high",
              pathname === "/dashboard" ? "bg-blu-surface-high text-blu-on" : "text-blu-on-variant",
            )}
          >
            <span className="w-4 text-center">▦</span> Panel
          </Link>
        </div>
      </div>

      {/* User */}
      <div className="border-t border-blu-outline/20 p-3">
        <Link
          href="/settings"
          onClick={() => setOpen(false)}
          className="flex items-center gap-3 rounded-lg p-2 hover:bg-blu-surface-high"
        >
          <div className="flex h-8 w-8 items-center justify-center rounded-full bg-blu-primary-solid text-xs font-bold text-white">
            {initials}
          </div>
          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-medium text-blu-on">{user?.displayName}</p>
            <p className="truncate text-xs text-blu-on-variant">{user?.plan}</p>
          </div>
          <span className="text-blu-on-variant">›</span>
        </Link>
        <button
          type="button"
          onClick={async () => {
            await logout();
            setOpen(false);
          }}
          className="mt-1 flex w-full items-center gap-2 rounded-lg px-2 py-1.5 text-sm text-blu-on-variant hover:bg-blu-surface-high hover:text-blu-on"
        >
          <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth="2">
            <path strokeLinecap="round" d="M17 16l4-4-4-4M21 12H9M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
          </svg>
          Cerrar sesión
        </button>
      </div>
    </aside>
  );
}
