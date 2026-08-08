// Capa DOMAIN: entidades puras, sin dependencias externas (ni NestJS, ni Prisma).

import type { PlanId, Role } from "@blu-ia/shared";

export interface UserEntity {
  id: string;
  email: string | null;
  phone: string | null;
  displayName: string;
  timezone: string;
  plan: PlanId;
  role: Role;
  tosAcceptedAt: Date | null;
  /** Hash opaco de la credencial — el dominio no sabe cómo se genera ni verifica. */
  passwordHash: string | null;
}
