"use client";

import { AppShell } from "@/components/shell/AppShell";

export default function MemoryPage() {
  return (
    <AppShell>
      <div className="mx-auto max-w-5xl p-6 md:p-8">
        <header className="mb-8">
          <h1 className="font-geist text-2xl font-semibold text-blu-on">Memory</h1>
          <p className="mt-1 text-sm text-blu-on-variant">Tus recuerdos, notas y conocimiento conectado.</p>
        </header>

        <div className="grid gap-4 md:grid-cols-3">
          {[
            { title: "Memories", desc: "Hechos y preferencias guardadas", icon: "🧠" },
            { title: "Notes", desc: "Notas de proyectos", icon: "📝" },
            { title: "Knowledge", desc: "Fuentes y conexiones", icon: "🔗" },
          ].map((c) => (
            <div key={c.title} className="rounded-xl border border-blu-outline/20 bg-blu-surface-low p-4">
              <div className="text-lg">{c.icon}</div>
              <h3 className="mt-2 font-medium text-blu-on">{c.title}</h3>
              <p className="mt-1 text-sm text-blu-on-variant">{c.desc}</p>
            </div>
          ))}
        </div>

        <div className="mt-8 rounded-xl border border-dashed border-blu-outline/30 bg-blu-surface/50 p-8 text-center">
          <p className="text-sm text-blu-on-variant">Visualización Graph próximamente — tus notas y conexiones en un grafo interactivo.</p>
        </div>
      </div>
    </AppShell>
  );
}
