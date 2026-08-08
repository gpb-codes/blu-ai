// Pruebas del context builder: qué memoria se inyecta al modelo y en qué orden.

import { describe, expect, it } from "vitest";
import { buildMemoryContext } from "../context-builder.js";
import type { Note } from "../types.js";

function note(id: string, title: string, bodyMd: string, tags: string[] = []): Note {
  const now = new Date("2026-01-08T00:00:00.000Z");
  return {
    id,
    projectId: "p1",
    title,
    bodyMd,
    tags,
    source: "chat",
    createdBy: "u1",
    updatedBy: "u1",
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  };
}

const L = (s: string, t: string) => ({ sourceNoteId: s, targetNoteId: t, label: null as string | null });

describe("buildMemoryContext", () => {
  it("respeta maxNotes (por defecto 5)", () => {
    const notes = Array.from({ length: 8 }, (_, i) => note(`n${i}`, `Nota ${i}`, "texto"));
    const ctx = buildMemoryContext({ relevantNotes: notes, links: [] });
    expect(ctx.notes).toHaveLength(5);
    expect(ctx.trail).toHaveLength(5);
  });

  it("incluye vecinos de 1er grado aunque se supere maxNotes", () => {
    const a = note("a", "Pedro", "[[María]]");
    const maria = note("b", "María", "amiga de pedro", ["amigos"]);
    const ctx = buildMemoryContext({ relevantNotes: [a, maria], links: [L("a", "b")], maxNotes: 1 });
    expect(ctx.notes.map((n) => n.id)).toEqual(["a", "b"]);
  });

  it("no duplica notas ni se pasa del máximo al añadir vecinos", () => {
    const a = note("a", "A", "[[B]]");
    const b = note("b", "B", "[[C]]");
    const c = note("c", "C", "");
    const ctx = buildMemoryContext({
      relevantNotes: [a, b, c],
      links: [L("a", "b"), L("b", "c")],
      maxNotes: 2,
    });
    expect(ctx.notes).toHaveLength(2);
  });

  it("mantiene títulos citados con [[wikilink]] aunque excedan maxNotes", () => {
    const red = note("r", "Redux", "gestión de estado");
    const flutter = note("f", "Flutter", "UI");
    const ctx = buildMemoryContext({
      relevantNotes: [flutter, red],
      citedTitles: ["Redux"],
      links: [],
      maxNotes: 1,
    });
    expect(ctx.notes.find((n) => n.id === "r")?.id).toBe(red.id);
  });

  it("arma el texto con título, tags y body separados", () => {
    const a = note("a", "Proyecto BLU", "Detalles del plan", ["ia", "plan"]);
    const ctx = buildMemoryContext({ relevantNotes: [a], links: [], maxNotes: 1 });
    expect(ctx.text).toContain("# Proyecto BLU");
    expect(ctx.text).toContain("tags: ia, plan");
    expect(ctx.text).toContain("Detalles del plan");
  });

  it("devuelve notas y trail vacíos si no hay nada relevante", () => {
    const ctx = buildMemoryContext({ relevantNotes: [], links: [] });
    expect(ctx.notes).toEqual([]);
    expect(ctx.text).toBe("");
  });
});