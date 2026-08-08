// Capa PRESENTATION: HTTP (REST). Solo traduce JSON ↔ casos de uso.

import { Controller, Get } from "@nestjs/common";

@Controller("health")
export class HealthController {
  @Get()
  check() {
    return { status: "ok", service: "blu-ia-api", version: "0.1.0" };
  }
}
