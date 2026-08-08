// Capa DOMAIN: repositorio del vault (second brain).
// La búsqueda semántica (embeddings/pgvector) es responsabilidad de la implementación,
// pero el contrato vive aquí.

import type { Note, NoteLink } from "@blu-ia/memory";

export interface VaultRepository {
  findByProject(projectId: string): Promise<Note[]>;
  findById(noteId: string): Promise<Note | null>;
  /** Búsqueda híbrida: semántica + tags + vecinos. Devuelve notas candidatas y el título. */
  search(projectId: string, query: string, limit?: number): Promise<Note[]>;
  create(note: Omit<Note, "id" | "createdAt" | "updatedAt" | "deletedAt">): Promise<Note>;
  update(noteId: string, body: { title?: string; bodyMd?: string; tags?: string[] }): Promise<Note>;
  links(projectId: string): Promise<NoteLink[]>;
}
