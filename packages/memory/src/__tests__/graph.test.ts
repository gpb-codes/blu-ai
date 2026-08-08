// Pruebas del grafo del vault (wikilinks, backlinks, vecinos y KnowledgeGraph).

import { describe, expect, it } from "vitest";
import { backlinks, buildGraph, buildLinks, extractWikilinks, neighbors } from "../graph.js";
import type { Note } from "../types.js";

function note(id: string, title: string, bodyMd: string, tags: string[] = []): Note {
  const now = new Date("2026-08-08T00:00:00.000Z");
  return {
    id,
    projectId: "p1",
    title,
    bodyMd,
    tags,
    source: "manual",
    createdBy: "u1",
    updatedBy: "u1",
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  };
}

describe("extractWikilinks", () => {
  it("extrae títulos de [[wikilinks]]", () => {
    expect(extractWikilinks("Mira [[Nota A]] y [[Nota B]], ok?")).toEqual(["Nota A", "Nota B"]);
  });

  it("soporta alias [[titulo|alias]]", () => {
    expect(extractWikilinks("[[Mi Vault|vault]]")).toEqual(["Mi Vault"]);
  });

  it("ignora wikilinks vacíos", () => {
    expect(extractWikilinks("[[ ]] y [[|alias]]")).toEqual([]);
  });

  it("no encuentra nada sin wikilinks", () => {
    expect(extractWikilinks("texto plano sin enlaces")).toEqual([]);
  });
});

describe("buildLinks", () => {
  const notes = [
    note("a", "Proyecto", "Ver [[ideas]] y [[idea-zombie]]"),
    note("b", "Ideas", "Relacionado con [[Proyecto]]"),
    note("c", "Suelta", "sin enlaces"),
  ];

  it("resuelve wikilinks a aristas por título (insensible a mayúsculas)", () => {
    const links = buildLinks(notes);
    expect(links).toContainEqual({ sourceNoteId: "a", targetNoteId: "b", label: null });
    expect(links).toContainEqual({ sourceNoteId: "b", targetNoteId: "a", label: null });
  });

  it("omite destinos que no existen y los self-links", () => {
    const links = buildLinks([note("a", "Yo", "[[Yo]] y [[NoExiste]]")]);
    expect(links).toEqual([]);
  });
});

describe("backlinks", () => {
  it("devuelve las notas que enlazan a la dada", () => {
    const links = buildLinks([
      note("a", "Raíz", "[[Destino]]"),
      note("b", "Otra", "[[Destino]] y [[Raíz]]"),
      note("d", "Destino", "fuera"),
    ]);
    const bl = backlinks("d", links);
    expect(bl.map((l) => l.sourceNoteId)).toEqual(["a", "b"]);
  });
});

describe("neighbors", () => {
  it("combina salientes y entrantes de 1er grado", () => {
    const links = [
      { sourceNoteId: "a", targetNoteId: "b", label: null },
      { sourceNoteId: "c", targetNoteId: "a", label: null },
      { sourceNoteId: "x", targetNoteId: "y", label: null },
    ];
    expect(neighbors("a", links).sort()).toEqual(["b", "c"]);
  });
});

describe("buildGraph", () => {
  it("arma nodos con título/tags y aristas solo entre notas existentes", () => {
    const notes = [note("a", "Raíz", "[[Hijo]]"), note("b", "Hijo", "")];
    const links = [{ sourceNoteId: "a", targetNoteId: "b", label: null }];
    const g = buildGraph(notes, links);
    expect(g.nodes).toHaveLength(2);
    expect(g.nodes[0]).toMatchObject({ id: "a", title: "Raíz", tags: [], folder: null });
    expect(g.edges).toEqual([{ source: "a", target: "b" }]);
  });

  it("descarta aristas hacia notas fuera del vault", () => {
    const links = [
      { sourceNoteId: "a", targetNoteId: "fantasma", label: null },
      { sourceNoteId: "a", targetNoteId: "b", label: null },
    ];
    const g = buildGraph([note("a", "A", ""), note("b", "B", "")], links);
    expect(g.edges).toEqual([{ source: "a", target: "b" }]);
  });
});