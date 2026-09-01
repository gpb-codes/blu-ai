// Capa PRESENTATION: controlador de auth. Mapea DTOs → AuthUseCase y traduce errores
// de dominio (Error("CODE")) a HTTP.

import { BadRequestException, Body, Controller, Get, HttpCode, Post, UnauthorizedException, UseGuards } from "@nestjs/common";
import { AuthUseCase } from "../../application/use-cases/auth.use-case.js";
import { CurrentUser, JwtAuthGuard, type AuthenticatedUser } from "../guards/jwt-auth.guard.js";
import { LoginDto, LogoutDto, RefreshDto, RegisterDto } from "../dto/auth.dto.js";

const HTTP_BY_CODE: Record<string, number> = {
  EMAIL_TAKEN: 409,
  INVALID_CREDENTIALS: 401,
  INVALID_REFRESH_TOKEN: 401,
};

@Controller("auth")
export class AuthController {
  constructor(private readonly auth: AuthUseCase) {}

  @Post("register")
  async register(@Body() dto: RegisterDto) {
    return this.run(() => this.auth.register(dto));
  }

  @HttpCode(200)
  @Post("login")
  async login(@Body() dto: LoginDto) {
    return this.run(() => this.auth.login(dto));
  }

  @HttpCode(200)
  @Post("refresh")
  async refresh(@Body() dto: RefreshDto) {
    return this.run(() => this.auth.refresh(dto));
  }

  @HttpCode(200)
  @Post("logout")
  async logout(@Body() dto: LogoutDto) {
    await this.auth.logout(dto);
    return { ok: true };
  }

  @UseGuards(JwtAuthGuard)
  @Get("me")
  me(@CurrentUser() user: AuthenticatedUser) {
    return { id: user.id };
  }

  private async run<T>(fn: () => Promise<T>): Promise<T> {
    try {
      return await fn();
    } catch (e) {
      const code = e instanceof Error ? e.message : "INTERNAL";
      const status = HTTP_BY_CODE[code];
      if (status === 401) throw new UnauthorizedException({ code, message: "Credenciales inválidas" });
      if (status === 409) throw new BadRequestException({ code, message: "El email ya está registrado" });
      throw e;
    }
  }
}
