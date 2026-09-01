// Capa PRESENTATION: controlador de chat protegido por JWT. El DTO define el contrato público.

import { Body, Controller, ForbiddenException, Post, ServiceUnavailableException, UseGuards } from "@nestjs/common";
import { ChatUseCase } from "../../application/use-cases/chat.use-case.js";
import { CurrentUser, JwtAuthGuard, type AuthenticatedUser } from "../guards/jwt-auth.guard.js";
import { SendMessageDto } from "../dto/chat.dto.js";

@UseGuards(JwtAuthGuard)
@Controller("chat")
export class ChatController {
  constructor(private readonly chat: ChatUseCase) {}

  @Post()
  async send(@CurrentUser() user: AuthenticatedUser, @Body() dto: SendMessageDto) {
    try {
      return await this.chat.execute({ ...dto, history: dto.history ?? [], userId: user.id });
    } catch (e) {
      const message = e instanceof Error ? e.message : "";
      if (message.includes("Sin API key")) {
        throw new ServiceUnavailableException({ code: "PROVIDER_NOT_CONFIGURED", message });
      }
      if (message === "Sin acceso a este proyecto") {
        throw new ForbiddenException({ code: "FORBIDDEN_PROJECT", message });
      }
      throw e;
    }
  }
}
