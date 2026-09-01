// Barra lateral con el diseño soybluia: logo, "Nuevo chat", sesiones recientes,
// tarjeta de usuario (avatar, plan) y Configuración. Ancho fijo de 280px.

"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { chatApi } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import { cn } from "@/lib/utils";
import type { ChatSession } from "@/types";

const NAV_ITEMS = [
  { href: "/dashboard", label: "Panel", icon: "▦" },
  { href: "/projects", label: "Proyectos", icon: "▤" },
];

export function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const { user, logout } = useAuth();
  const [recent, setRecent] = useState<ChatSession[]>([]);

  useEffect(() => {
    void chatApi
      .sessions()
      .then((s) => setRecent(s.slice(0, 6)))
      .catch(() => setRecent([]));
  }, []);

  const initials = (user?.displayName ?? "?")
    .split(" ")
    .map((w) => w.charAt(0))
    .join("")
    .slice(0, 2)
    .toUpperCase();

  return (
    <aside className="flex w-[280px] shrink-0 flex-col border-r border-blu-outline/30 bg-blu-surface-low">
      <div className="flex items-center gap-3 px-6 pt-4">
        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blu-primary-solid">
          <svg viewBox="0 0 24 24" className="h-4 w-4 text-white" fill="currentColor" aria-hidden>
            <path d="M13 2 4.5 13.5h5L11 22l8.5-11.5h-5L13 2z" />
          </svg>
        </div>
        <span className="text-xl font-bold text-blu-on">soybluia</span>
      </div>

      <nav className="mt-8 flex flex-1 flex-col gap-1 px-6">
        <button
          type="button"
          onClick={() => router.push("/chat")}
          className="flex items-center gap-2 rounded-lg bg-blu-surface-high px-4 py-3 text-sm font-medium text-blu-on transition-colors hover:bg-blu-surface-highest"
        >
          <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden>
            <path strokeLinecap="round" d="M12 5v14M5 12h14" />
          </svg>
          Nuevo chat
        </button>

        <div className="mt-6">
          <p className="px-1 text-[10px] font-medium uppercase tracking-widest text-blu-on-variant/70">Recientes</p>
          <div className="mt-2 space-y-0.5">
            {recent.length === 0 ? (
              <p className="px-3 py-2 text-sm text-blu-on-variant/70">Sin conversaciones</p>
            ) : (
              recent.map((session) => (
                <Link
                  key={session.id}
                  href={`/chat?session=${session.id}`}
                  className={cn(
                    "flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm transition-colors hover:bg-blu-surface-high",
                    pathname === "/chat" ? "text-blu-on" : "text-blu-on-variant/80",
                  )}
                >
                  <span className="text-blu-on-variant/60">💬</span>
                  <span className="truncate">{session.title}</span>
                </Link>
              ))
            )}
          </div>
        </div>

        <div className="mt-6 space-y-0.5">
          {NAV_ITEMS.map((item) => {
            const active = pathname === item.href || (item.href !== "/dashboard" && pathname.startsWith(item.href));
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  "flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm transition-colors",
                  active ? "bg-blu-surface-high text-blu-on" : "text-blu-on-variant/80 hover:bg-blu-surface-high",
                )}
              >
                <span className="w-4 text-center">{item.icon}</span>
                {item.label}
              </Link>
            );
          })}
        </div>
      </nav>

      <div className="mt-auto space-y-2 px-6 pb-4">
        <Link
          href="/settings"
          className={cn(
            "flex items-center gap-3 rounded-lg p-2 text-sm transition-colors",
            pathname === "/settings" ? "bg-blu-surface-high text-blu-on" : "text-blu-on hover:bg-blu-surface-high",
          )}
        >
          <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-blu-primary-soft text-xs font-bold text-white">
            {initials}
          </div>
          <div className="min-w-0 flex-1">
            <p className="truncate text-[13px] text-blu-on">{user?.displayName}</p>
            <p className="text-[11px] text-blu-on-variant">Plan {user?.plan}</p>
          </div>
        </Link>
        <button
          type="button"
          onClick={async () => {
            await logout();
            router.push("/auth/login");
          }}
          className="flex w-full items-center gap-3 rounded-lg p-2 text-left text-[13px] text-blu-on transition-colors hover:bg-blu-surface-high"
        >
          <svg viewBox="0 0 24 24" className="h-5 w-5 text-blu-on-variant" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden>
            <path strokeLinecap="round" strokeLinejoin="round" d="M10.3 6.7a6 6 0 1 0 7 7M12 2v9" />
          </svg>
          Cerrar sesión
        </button>
      </div>
    </aside>
  );
}