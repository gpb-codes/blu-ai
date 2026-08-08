// Capa INFRASTRUCTURE: estrategia passport-jwt. El JWT_SIGNING_SECRET viene de ConfigModule.

import { Injectable, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { ExtractJwt, Strategy } from "passport-jwt";
import { JwtTokenService } from "./jwt-token.service.js";

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly tokens: JwtTokenService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET ?? "dev-secret-change-me",
    });
  }

  async validate(payload: { sub: string }) {
    if (!payload.sub) throw new UnauthorizedException();
    return { id: payload.sub };
  }
}