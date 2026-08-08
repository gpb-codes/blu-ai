// Capa PRESENTATION: controlador de chat protegido por JWT. El DTO define el contrato público.

import { Body, Controller, Post, UseGuards } from "@nestjs/common";
import { ChatUseCase } from "../../application/use-cases/chat.use-case.js";
import { CurrentUser, JwtAuthGuard, type AuthenticatedUser } from "../guards/jwt-auth.guard.js";
import { SendMessageDto } from "../dto/chat.dto.js";

@UseGuards(JwtAuthGuard)
@Controller("chat")
export class ChatController {
  constructor(private readonly chat: ChatUseCase) {}

  @Post()
  async send(@CurrentUser() user: AuthenticatedUser, @Body() dto: SendMessageDto) {
    return this.chat.execute({ ...dto, history: dto.history ?? [], userId: user.id });
  }
}
