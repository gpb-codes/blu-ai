// Operaciones de grafo del vault: wikilinks, backlinks, vecinos y gráfico de conocimiento.
// Lógica pura — recibe listas, devuelve resultados (testeable sin DB).

import { WIKILINK_RE } from "./types.js";
import type { GraphEdge, GraphNode, KnowledgeGraph, Note, NoteLink } from "./types.js";

/** Extrae los títulos referenciados con [[wikilink]] de un body Markdown. */
export function extractWikilinks(bodyMd: string): string[] {
  const titles: string[] = [];
  for (const m of bodyMd.matchAll(WIKILINK_RE)) {
    const title = (m[1] ?? "").trim();
    if (title) titles.push(title);
  }
  return titles;
}

/** Resuelve wikilinks a aristas (nota fuente → nota destino). Los destinos inexistentes se omiten. */
export function buildLinks(notes: Note[]): NoteLink[] {
  const byTitle = new Map<string, string>();
  for (const n of notes) byTitle.set(n.title.toLowerCase(), n.id);

  const links: NoteLink[] = [];
  for (const n of notes) {
    for (const title of extractWikilinks(n.bodyMd)) {
      const targetId = byTitle.get(title.toLowerCase());
      if (targetId && targetId !== n.id) {
        links.push({ sourceNoteId: n.id, targetNoteId: targetId, label: null });
      }
    }
  }
  return links;
}

/** Backlinks de una nota = notas que la enlazan. */
export function backlinks(noteId: string, links: NoteLink[]): NoteLink[] {
  return links.filter((l) => l.targetNoteId === noteId);
}

/** Vecinos de 1er grado (salientes + entrantes) — base del gráfico de conocimiento. */
export function neighbors(noteId: string, links: NoteLink[]): string[] {
  const out = new Set<string>();
  for (const l of links) {
    if (l.sourceNoteId === noteId) out.add(l.targetNoteId);
    if (l.targetNoteId === noteId) out.add(l.sourceNoteId);
  }
  return [...out];
}

/** Arma el grafo completo del vault para la vista estilo Obsidian. */
export function buildGraph(notes: Note[], links: NoteLink[]): KnowledgeGraph {
  const byId = new Map(notes.map((n) => [n.id, n]));
  const nodes: GraphNode[] = notes.map((n) => ({
    id: n.id,
    title: n.title,
    tags: n.tags,
    folder: null, // pendiente: carpetas virtuales por tag (fase 5)
  }));
  const edges: GraphEdge[] = [];
  for (const l of links) {
    if (byId.has(l.sourceNoteId) && byId.has(l.targetNoteId)) {
      edges.push({ source: l.sourceNoteId, target: l.targetNoteId });
    }
  }
  return { nodes, edges };
}
