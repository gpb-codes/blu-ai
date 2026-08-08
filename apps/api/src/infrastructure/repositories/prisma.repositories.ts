// Capa INFRASTRUCTURE: implementaciones de los repositorios del dominio sobre Prisma.
// Aquí vive el mapeo Prisma → entidades de dominio (nada de Prisma se fuga hacia arriba).

import { Injectable } from "@nestjs/common";
import type { Note, NoteLink } from "@blu-ia/memory";
import type { UserEntity } from "../../domain/entities/user.entity.js";
import type { ProjectRepository, UserRepository } from "../../domain/repositories/repositories.js";
import type { VaultRepository } from "../../domain/repositories/vault.repository.js";
import { PrismaService } from "../database/prisma.service.js";

@Injectable()
export class PrismaUserRepository implements UserRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string): Promise<UserEntity | null> {
    const u = await this.prisma.user.findUnique({ where: { id } });
    return u ? this.map(u) : null;
  }

  async findByEmail(email: string): Promise<UserEntity | null> {
    const u = await this.prisma.user.findUnique({ where: { email } });
    return u ? this.map(u) : null;
  }

  async findByPhone(phone: string): Promise<UserEntity | null> {
    const u = await this.prisma.user.findUnique({ where: { phone } });
    return u ? this.map(u) : null;
  }

  async create(data: { email?: string; phone?: string; displayName: string; passwordHash?: string }): Promise<UserEntity> {
    const u = await this.prisma.user.create({
      data: { email: data.email ?? null, phone: data.phone ?? null, displayName: data.displayName, passwordHash: data.passwordHash ?? null },
    });
    return this.map(u);
  }

  private map(u: {
    id: string;
    email: string | null;
    phone: string | null;
    displayName: string;
    timezone: string;
    plan: UserEntity["plan"];
    role: UserEntity["role"];
    tosAcceptedAt: Date | null;
    passwordHash: string | null;
  }): UserEntity {
    return u;
  }
}

@Injectable()
export class PrismaProjectRepository implements ProjectRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findMembership(projectId: string, userId: string) {
    const m = await this.prisma.projectMember.findUnique({
      where: { projectId_userId: { projectId, userId } },
      select: { role: true },
    });
    return m;
  }
}

@Injectable()
export class PrismaVaultRepository implements VaultRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findByProject(projectId: string): Promise<Note[]> {
    return this.prisma.note.findMany({ where: { projectId, deletedAt: null } });
  }

  async findById(noteId: string): Promise<Note | null> {
    return this.prisma.note.findUnique({ where: { id: noteId } });
  }

  async search(projectId: string, query: string, limit = 8): Promise<Note[]> {
    // TODO Fase 5: búsqueda híbrida con pgvector (semántica) + tags + grafo.
    // Mientras tanto: match simple por título/cuerpo.
    return this.prisma.note.findMany({
      where: {
        projectId,
        deletedAt: null,
        OR: [
          { title: { contains: query, mode: "insensitive" } },
          { bodyMd: { contains: query, mode: "insensitive" } },
        ],
      },
      take: limit,
    });
  }

  async create(note: Omit<Note, "id" | "createdAt" | "updatedAt" | "deletedAt">): Promise<Note> {
    return this.prisma.note.create({
      data: {
        projectId: note.projectId,
        title: note.title,
        bodyMd: note.bodyMd,
        tags: note.tags,
        source: note.source,
        createdBy: note.createdBy,
        updatedBy: note.updatedBy,
      },
    });
  }

  async update(noteId: string, body: { title?: string; bodyMd?: string; tags?: string[] }): Promise<Note> {
    return this.prisma.note.update({ where: { id: noteId }, data: body });
  }

  async links(projectId: string): Promise<NoteLink[]> {
    return this.prisma.noteLink.findMany({
      where: { sourceNote: { projectId } },
    });
  }
}
