// Vault "second brain" estilo Obsidian: notas Markdown con wikilinks, tags y backlinks.
// Este paquete contiene el dominio puro (sin base de datos); la persistencia vive en
// apps/api/infrastructure/database (Prisma + pgvector).

export type NoteSource = "chat" | "manual" | "agent" | "import";

export interface Note {
  id: string;
  projectId: string;
  title: string;
  bodyMd: string;
  tags: string[];
  source: NoteSource;
  createdBy: string;
  updatedBy: string;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
}

export interface NoteLink {
  sourceNoteId: string;
  targetNoteId: string;
  label: string | null; // texto del enlace en el body
}

export interface NoteChunk {
  noteId: string;
  index: number;
  text: string;
  embedding?: number[]; // vector — lo llena la infraestructura
}

export interface NoteVersion {
  noteId: string;
  version: number;
  bodyMd: string;
  editedBy: string;
  editedAt: Date;
}

/** Nodo del gráfico de conocimiento (vista Obsidian). */
export interface GraphNode {
  id: string;
  title: string;
  tags: string[];
  folder: string | null;
}

export interface GraphEdge {
  source: string;
  target: string;
}

export interface KnowledgeGraph {
  nodes: GraphNode[];
  edges: GraphEdge[];
}

/** Menciones [[wikilink]] extraídas del body de una nota. */
export const WIKILINK_RE = /\[\[([^\]|]+)(?:\|([^\]]+))?\]\]/g;
