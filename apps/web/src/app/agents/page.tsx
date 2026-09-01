"use client";

import { AppShell } from "@/components/shell/AppShell";

const AGENTS = [
  { name: "Plan", desc: "Divide el trabajo y define el plan", icon: "📋" },
  { name: "Build", desc: "Escribe y corrige código", icon: "💻" },
  { name: "Cowork", desc: "Trabaja contigo en tareas conjuntas", icon: "👥" },
  { name: "Research", desc: "Investiga y resume fuentes", icon: "🔍" },
  { name: "QA", desc: "Prueba y detecta fallos", icon: "🐛" },
  { name: "Knowledge", desc: "Recupera y organiza la memoria", icon: "📚" },
];

export default function AgentsPage() {
  return (
    <AppShell>
      <div className="mx-auto max-w-5xl p-6 md:p-8">
        <header className="mb-8 flex items-center justify-between">
          <div>
            <h1 className="font-geist text-2xl font-semibold text-blu-on">Agents</h1>
            <p className="mt-1 text-sm text-blu-on-variant">Elige un agente para tu próxima conversación.</p>
          </div>
          <button type="button" className="rounded-lg bg-blu-primary-solid px-4 py-2 text-sm font-medium text-white hover:bg-blu-primary">
            Crear agente
          </button>
        </header>
        <div className="grid gap-4 md:grid-cols-3">
          {AGENTS.map((a) => (
            <div key={a.name} className="rounded-xl border border-blu-outline/20 bg-blu-surface-low p-4 hover:border-blu-primary/30">
              <div className="text-lg">{a.icon}</div>
              <h3 className="mt-2 font-medium text-blu-on">{a.name}</h3>
              <p className="mt-1 text-sm text-blu-on-variant">{a.desc}</p>
              <p className="mt-3 text-xs text-blu-primary">Seleccionar →</p>
            </div>
          ))}
        </div>
      </div>
    </AppShell>
  );
}
