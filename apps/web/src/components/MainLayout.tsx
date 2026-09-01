// Layout protegido — ahora delega a AppShell (ChatGPT shell) para mantener compatibilidad.

"use client";

import { AppShell } from "@/components/shell/AppShell";

export function MainLayout({ children }: { children: React.ReactNode }) {
  return (
    <AppShell>
      <div className="min-w-0 flex-1 p-6 md:p-8">{children}</div>
    </AppShell>
  );
}