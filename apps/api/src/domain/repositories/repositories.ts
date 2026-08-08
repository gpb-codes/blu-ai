// Capa DOMAIN: contratos de repositorios (interfaces). Las implementaciones viven en
// infrastructure/ (Prisma). Los casos de uso dependen de estas interfaces, no de Prisma.

import type { UserEntity } from "../entities/user.entity.js";

export interface UserRepository {
  findById(id: string): Promise<UserEntity | null>;
  findByEmail(email: string): Promise<UserEntity | null>;
  findByPhone(phone: string): Promise<UserEntity | null>;
  create(data: { email?: string; phone?: string; displayName: string; passwordHash?: string }): Promise<UserEntity>;
}

import type { MemberRole } from "@blu-ia/shared";

export interface ProjectRepository {
  findMembership(projectId: string, userId: string): Promise<{ role: MemberRole } | null>;
}
