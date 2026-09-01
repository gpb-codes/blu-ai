// Layout protegido: sin sesión redirige a /auth/login. Muestra sidebar + contenido.

"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { Sidebar } from "@/components/Sidebar";
import { useAuth } from "@/lib/auth-context";

export function MainLayout({ children }: { children: React.ReactNode }) {
  const { status } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (status === "unauthenticated") router.replace("/auth/login");
  }, [status, router]);

  if (status === "loading") {
    return (
      <div className="flex min-h-screen items-center justify-center bg-blu-bg">
        <div className="flex flex-col items-center gap-3">
          <div className="h-10 w-10 animate-spin rounded-full border-2 border-blu-primary border-t-transparent" />
          <p className="text-sm text-blu-on-variant">Cargando…</p>
        </div>
      </div>
    );
  }

  if (status !== "authenticated") return null;

  return (
    <div className="flex min-h-screen bg-blu-bg">
      <Sidebar />
      <main className="min-w-0 flex-1 p-6 md:p-8">{children}</main>
    </div>
  );
}