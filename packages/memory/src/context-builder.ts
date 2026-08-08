// Context builder: arma el contexto que se inyecta a CUALQUIER modelo.
// Entrega la ruta de notas relevantes (semántica + tags + vecinos del grafo),
// no el vault completo. Así la memoria no depende del modelo.

import { neighbors } from "./graph.js";
import type { Note, NoteLink } from "./types.js";

export interface ContextOptions {
  /** Notas candidatas del vault (ya filtradas por búsqueda semántica en infraestructura). */
  relevantNotes: Note[];
  links: NoteLink[];
  /** Notas citadas explícitamente por el usuario con [[wikilink]]. */
  citedTitles?: string[];
  maxNotes?: number;
  includeGraphTrail?: boolean;
}

export interface MemoryContext {
  notes: Note[];
  trail: string[]; // títulos incluidos, en orden de relevancia
  text: string; // bloque de texto listo para inyectar al prompt
}

/** Contexto para el modelo: notas relevantes + sus vecinos de 1er grado (1 salto). */
export function buildMemoryContext(opts: ContextOptions): MemoryContext {
  const max = opts.maxNotes ?? 5;
  const byTitle = new Map(opts.relevantNotes.map((n) => [n.title.toLowerCase(), n]));
  const selected: Note[] = [];
  const seen = new Set<string>();

  for (const n of opts.relevantNotes) {
    if (seen.has(n.id)) continue;
    seen.add(n.id);
    selected.push(n);
    if (selected.length >= max) break;
  }

  // Vecinos de 1er grado de las notas elegidas (solo si hay cupo).
  if (opts.includeGraphTrail !== false) {
    for (const n of [...selected]) {
      for (const nid of neighbors(n.id, opts.links)) {
        const neighbor = opts.relevantNotes.find((r) => r.id === nid);
        if (neighbor && !seen.has(nid)) {
          seen.add(nid);
          selected.push(neighbor);
          if (selected.length >= max) break;
        }
      }
      if (selected.length >= max) break;
    }
  }

  // Notas citadas por el usuario: van SIEMPRE, aunque excedan maxNotes (cita explícita gana).
  for (const title of opts.citedTitles ?? []) {
    const n = byTitle.get(title.toLowerCase());
    if (n && !seen.has(n.id)) {
      seen.add(n.id);
      selected.push(n);
    }
  }

  const text = selected
    .map(
      (n) =>
        `# ${n.title}\n${n.tags.length ? `tags: ${n.tags.join(", ")}\n` : ""}${n.bodyMd}`,
    )
    .join("\n\n---\n\n");

  return { notes: selected, trail: selected.map((n) => n.title), text };
}
