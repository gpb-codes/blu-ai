// Capa APPLICATION: casos de uso. No conocen NestJS ni Prisma — dependen de las
// interfaces del dominio y de los paquetes @blu-ia/*.

import type { AgentId, TierId } from "@blu-ia/shared";
import { invokeChat, TierRouter, type ChatInvocation } from "@blu-ia/ai-gateway";
import { buildMemoryContext } from "@blu-ia/memory";
import type { VaultRepository } from "../../domain/repositories/vault.repository.js";
import type { ProjectRepository } from "../../domain/repositories/repositories.js";

export interface ChatRequestInput {
  userId: string;
  projectId?: string;
  agentId?: AgentId;
  tier: TierId | "auto";
  text: string;
  history: Array<{ role: "user" | "assistant"; content: string }>;
  userApiKeys?: ChatInvocation["userApiKeys"];
}

export interface ChatResultOutput {
  content: string;
  usedModel: string;
  citedNotes: string[];
  costUsd: number;
  creditsSpent: number;
}

export class ChatUseCase {
  constructor(
    private readonly gateway: TierRouter,
    private readonly vault: VaultRepository,
    private readonly projects: ProjectRepository,
  ) {}

  /** Flujo completo: permisos → contexto del vault → gateway → respuesta. */
  async execute(input: ChatRequestInput): Promise<ChatResultOutput> {
    if (input.projectId) {
      const membership = await this.projects.findMembership(input.projectId, input.userId);
      if (!membership) throw new Error("Sin acceso a este proyecto");
    }

    let citedNotes: string[] = [];
    let memoryText = "";

    if (input.projectId) {
      const notes = await this.vault.search(input.projectId, input.text, 8);
      const links = await this.vault.links(input.projectId);
      const ctx = buildMemoryContext({ relevantNotes: notes, links, maxNotes: 5 });
      citedNotes = ctx.notes.map((n) => n.id);
      memoryText = ctx.text ? `Memoria del proyecto:\n${ctx.text}` : "";
    }

    const result = await invokeChat(this.gateway, {
      userId: input.userId,
      plan: "FREE", // TODO Fase 10: resolver plan real del usuario
      tier: input.tier,
      text: input.text,
      history: input.history,
      userApiKeys: input.userApiKeys,
    });

    return {
      content: result.content,
      usedModel: result.usage.model,
      citedNotes,
      costUsd: result.usage.costUsd,
      creditsSpent: result.creditsSpent,
    };
  }
}
