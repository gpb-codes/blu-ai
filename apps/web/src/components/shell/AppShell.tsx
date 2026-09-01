"use client";

import { createContext, useContext, useEffect, useState } from "react";
import { Sidebar } from "@/components/shell/Sidebar";
import { useAuth } from "@/lib/auth-context";
import { useRouter } from "next/navigation";

const SidebarContext = createContext<{
  open: boolean;
  setOpen: (v: boolean) => void;
  collapsed: boolean;
  setCollapsed: (v: boolean) => void;
} | null>(null);

export function useSidebar() {
  const ctx = useContext(SidebarContext);
  if (!ctx) return { open: false, setOpen: (_v: boolean) => {}, collapsed: false, setCollapsed: (_v: boolean) => {} };
  return ctx;
}

export function AppShell({ children }: { children: React.ReactNode }) {
  const { status } = useAuth();
  const router = useRouter();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);

  useEffect(() => {
    if (status === "unauthenticated") router.replace("/auth/login");
  }, [status, router]);

  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth >= 768) setSidebarOpen(false);
    };
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  if (status === "loading") {
    return (
      <div className="flex min-h-screen items-center justify-center bg-blu-bg">
        <div className="flex flex-col items-center gap-3">
          <div className="h-8 w-8 animate-spin rounded-full border-2 border-blu-primary-solid border-t-transparent" />
          <p className="text-sm text-blu-on-variant">Cargando BLU…</p>
        </div>
      </div>
    );
  }
  if (status !== "authenticated") return null;

  return (
    <SidebarContext.Provider value={{ open: sidebarOpen, setOpen: setSidebarOpen, collapsed, setCollapsed }}>
      <div className="flex h-screen overflow-hidden bg-blu-bg">
        {/* Desktop */}
        <div className={`${collapsed ? "w-[72px]" : "w-[260px]"} hidden shrink-0 transition-all duration-200 md:block`}>
          <Sidebar />
        </div>

        {/* Mobile drawer */}
        {sidebarOpen && (
          <div className="fixed inset-0 z-50 flex md:hidden">
            <div className="w-[280px] shrink-0">
              <Sidebar mobile />
            </div>
            <button
              type="button"
              aria-label="Cerrar menú"
              className="flex-1 bg-black/40 backdrop-blur-sm"
              onClick={() => setSidebarOpen(false)}
            />
          </div>
        )}

        <div className="flex min-w-0 flex-1 flex-col overflow-hidden">{children}</div>
      </div>
    </SidebarContext.Provider>
  );
}
