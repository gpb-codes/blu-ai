// Vault second brain — dominio puro (sin dependencias de infraestructura).
// Persistencia: Prisma + pgvector en apps/api/infrastructure.

export * from "./types.js";
export { extractWikilinks, buildLinks, backlinks, neighbors, buildGraph } from "./graph.js";
export { buildMemoryContext } from "./context-builder.js";
