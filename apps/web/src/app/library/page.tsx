"use client";

import { AppShell } from "@/components/shell/AppShell";

export default function LibraryPage() {
  return (
    <AppShell>
      <div className="mx-auto max-w-5xl p-6 md:p-8">
        <header className="mb-8">
          <h1 className="font-geist text-2xl font-semibold text-blu-on">Library</h1>
          <p className="mt-1 text-sm text-blu-on-variant">Archivos, imágenes y contenido generado en un solo lugar.</p>
        </header>
        <div className="flex gap-2 border-b border-blu-outline/20 pb-3 text-sm">
          {["Todos", "Archivos", "Imágenes", "Artifacts"].map((t, i) => (
            <button
              key={t}
              type="button"
              className={`rounded-full px-3 py-1 ${i === 0 ? "bg-blu-surface-high text-blu-on" : "text-blu-on-variant hover:bg-blu-surface-high"}`}
            >
              {t}
            </button>
          ))}
        </div>
        <div className="mt-6 grid gap-4 md:grid-cols-4">
          {[1, 2, 3, 4, 5, 6].map((n) => (
            <div key={n} className="aspect-[4/3] rounded-xl border border-blu-outline/20 bg-blu-surface-low p-3">
              <div className="h-20 rounded bg-blu-surface-high" />
              <p className="mt-2 text-sm font-medium text-blu-on">Archivo {n}.pdf</p>
              <p className="text-xs text-blu-on-variant">Hace 2 días</p>
            </div>
          ))}
        </div>
      </div>
    </AppShell>
  );
}
