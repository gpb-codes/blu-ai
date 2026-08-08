// Capa PRESENTATION: DTO del chat con validación. Con whitelist:true, todo campo
// sin decorador se elimina — por eso aquí TODO tiene reglas.

import { IsArray, IsEnum, IsIn, IsObject, IsOptional, IsString, MaxLength, MinLength } from "class-validator";
import type { AgentId } from "@blu-ia/shared";

const TIERS = ["light", "flash", "ultra", "auto"] as const;
const AGENTS = ["plan", "build", "cowork", "research", "qa", "automation", "knowledge"] as const;

export class HistoryItemDto {
  @IsIn(["user", "assistant"])
  role!: "user" | "assistant";

  @IsString()
  @MaxLength(100000)
  content!: string;
}

export class SendMessageDto {
  @IsOptional()
  @IsString()
  projectId?: string;

  @IsOptional()
  @IsIn(AGENTS)
  agentId?: AgentId;

  @IsIn(TIERS)
  tier: (typeof TIERS)[number] = "auto";

  @IsString()
  @MinLength(1)
  @MaxLength(30000)
  text!: string;

  @IsOptional()
  @IsArray()
  history?: HistoryItemDto[];
}
