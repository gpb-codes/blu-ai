// Pruebas unitarias de ChatUseCase: permisos por proyecto, inyección de memoria
// del vault y flujo por el gateway (fakes; los adapters reales son Fase 2).

import { describe, expect, it } from "vitest";
import { ChatUseCase } from "../chat.use-case.js";
import type { Note } from "@blu-ia/memory";
import type { ChatResult } from "@blu-ia/ai-gateway";

function makeNote(id: string, title: string, bodyMd: string): Note {
  const now = new Date();
  return {
    id,
    projectId: "p1",
    title,
    bodyMd,
    tags: [],
    source: "chat",
    createdBy: "u1",
    updatedBy: "u1",
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  };
}

/** Falso gateway que registra las llamadas y responde sin tocar proveedores. */
class FakeGateway {
  calls: Array<{ tier: string; text: string }> = [];
  resolve() {
    return { provider: "openai" as const, model: "gpt-4o-mini" };
  }
  async chat(tier: string, req: { messages: Array<{ content: string }> }): Promise<ChatResult> {
    this.calls.push({ tier, text: req.messages.at(-1)?.content ?? "" });
    return {
      content: "respuesta de prueba",
      provider: "openai",
      model: "gpt-4o-mini",
      usage: { inputTokens: 100, outputTokens: 50 },
    };
  }
}

class FakeProjects {
  constructor(private readonly member: boolean) {}
  async findMembership() {
    return this.member ? { projectId: "p1", userId: "u1" } : null;
  }
}

class FakeVault {
  constructor(
    private readonly notes: Note[],
    private readonly linkList: Array<{ sourceNoteId: string; targetNoteId: string; label: null }> = [],
  ) {}
  async search() {
    return this.notes;
  }
  async links() {
    return this.linkList;
  }
}

describe("ChatUseCase.execute", () => {
  it("rechaza mensajes a un proyecto del que el usuario no es miembro", async () => {
    const uc = new ChatUseCase(
      new FakeGateway() as never,
      new FakeVault([]) as never,
      new FakeProjects(false) as never,
    );
    await expect(
      uc.execute({ userId: "u1", projectId: "p-ajeno", tier: "light", text: "hola", history: [] }),
    ).rejects.toThrow("Sin acceso a este proyecto");
  });

  it("sin projectId no consulta el vault y responde vía gateway", async () => {
    const gateway = new FakeGateway();
    const uc = new ChatUseCase(gateway as never, new FakeVault([]) as never, new FakeProjects(true) as never);
    const res = await uc.execute({ userId: "u1", tier: "light", text: "hola blu", history: [] });
    expect(res.content).toBe("respuesta de prueba");
    expect(res.usedModel).toBe("gpt-4o-mini");
    expect(res.citedNotes).toEqual([]);
    expect(gateway.calls).toHaveLength(1);
    expect(gateway.calls[0]).toMatchObject({ tier: "light", text: "hola blu" });
  });

  it("con proyecto: busca en el vault, inyecta la memoria y reporta las citas", async () => {
    const gateway = new FakeGateway();
    const vault = new FakeVault([makeNote("n1", "Plan BLU", "Detalles del plan")]);
    const uc = new ChatUseCase(gateway as never, vault as never, new FakeProjects(true) as never);
    const res = await uc.execute({
      userId: "u1",
      projectId: "p1",
      tier: "light",
      text: "usa la memoria",
      history: [{ role: "user", content: "previo" }],
    });
    expect(res.citedNotes).toEqual(["n1"]);
    expect(gateway.calls[0]?.text).toBe("usa la memoria");
  });
});