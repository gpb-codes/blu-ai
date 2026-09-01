"use client";

import { AppShell } from "@/components/shell/AppShell";

export default function ArtifactsPage() {
  return (
    <AppShell>
      <div className="mx-auto max-w-5xl p-6 md:p-8">
        <header className="mb-8">
          <h1 className="font-geist text-2xl font-semibold text-blu-on">Artifacts</h1>
          <p className="mt-1 text-sm text-blu-on-variant">Código, documentos y apps interactivas generadas por BLU.</p>
        </header>
        <div className="grid gap-4 md:grid-cols-2">
          {[
            { title: "Dashboard Q1", type: "HTML", desc: "Preview interactivo" },
            { title: "Análisis CSV", type: "Code", desc: "Python • 42 líneas" },
            { title: "Diagrama flujo", type: "SVG", desc: "Mermaid" },
          ].map((a) => (
            <div key={a.title} className="rounded-xl border border-blu-outline/20 bg-blu-surface-low p-4">
              <div className="flex items-center justify-between">
                <span className="rounded bg-blu-surface-high px-2 py-0.5 text-xs text-blu-on-variant">{a.type}</span>
                <span className="text-xs text-blu-on-variant">⋯</span>
              </div>
              <h3 className="mt-3 font-medium text-blu-on">{a.title}</h3>
              <p className="text-sm text-blu-on-variant">{a.desc}</p>
              <div className="mt-3 flex gap-2 text-xs">
                <button type="button" className="rounded bg-blu-surface-high px-2 py-1 hover:bg-blu-surface">Preview</button>
                <button type="button" className="rounded bg-blu-surface-high px-2 py-1 hover:bg-blu-surface">Copy</button>
                <button type="button" className="rounded bg-blu-primary-solid px-2 py-1 text-white">Export</button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </AppShell>
  );
}
