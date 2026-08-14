// Barra lateral de navegación con el usuario real (nombre, plan) y cierre de sesión.

"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { Button } from "@/components/Button";
import { useAuth } from "@/lib/auth-context";
import { cn } from "@/lib/utils";

const LINKS = [
  { href: "/dashboard", label: "Panel", icon: "▦" },
  { href: "/projects", label: "Proyectos", icon: "▤" },
  { href: "/chat", label: "Chat", icon: "✎" },
  { href: "/settings", label: "Ajustes", icon: "⚙" },
];

export function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const { user, logout } = useAuth();

  return (
    <aside className="flex w-16 shrink-0 flex-col border-r border-slate-200 bg-white md:w-60 dark:border-slate-800 dark:bg-slate-900">
      <div className="flex h-16 items-center gap-3 border-b border-slate-200 px-4 dark:border-slate-800">
        <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-indigo-600 font-bold text-white">B</div>
        <span className="hidden text-lg font-semibold text-slate-900 md:block dark:text-slate-100">BLU</span>
      </div>

      <nav className="flex-1 space-y-1 p-3">
        {LINKS.map((link) => {
          const active = pathname === link.href || (link.href !== "/dashboard" && pathname.startsWith(link.href));
          return (
            <Link
              key={link.href}
              href={link.href}
              className={cn(
                "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors",
                active
                  ? "bg-indigo-50 text-indigo-700 dark:bg-indigo-950/50 dark:text-indigo-300"
                  : "text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800",
              )}
            >
              <span className="w-5 text-center">{link.icon}</span>
              <span className="hidden md:inline">{link.label}</span>
            </Link>
          );
        })}
      </nav>

      <div className="border-t border-slate-200 p-3 dark:border-slate-800">
        <div className="hidden items-center gap-3 md:flex">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-slate-200 text-sm font-semibold text-slate-700 dark:bg-slate-800 dark:text-slate-200">
            {(user?.displayName ?? "?").charAt(0).toUpperCase()}
          </div>
          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-medium text-slate-900 dark:text-slate-100">{user?.displayName}</p>
            <p className="text-xs text-slate-500 dark:text-slate-400">{user?.plan}</p>
          </div>
        </div>
        <Button
          variant="ghost"
          size="sm"
          className="mt-2 w-full justify-start"
          onClick={async () => {
            await logout();
            router.push("/auth/login");
          }}
        >
          <span className="hidden md:inline">Cerrar sesión</span>
          <span className="md:hidden">⏻</span>
        </Button>
      </div>
    </aside>
  );
}