// E2E del flujo de auth contra la API real (Nest + Prisma + Postgres en Docker).
// Requiere: contenedor `blu-pg` corriendo con la extensión vector y migraciones aplicadas.
// Email único por corrida para no chocar con datos previos.

import { describe, expect, it, beforeAll, afterAll } from "vitest";
import type { INestApplication } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";
import { ValidationPipe } from "@nestjs/common";
import request from "supertest";
import { AppModule } from "../src/app.module";

describe("Auth E2E", () => {
  let app: INestApplication;
  const email = `e2e-${Date.now()}@blu.test`;

  beforeAll(async () => {
    app = await NestFactory.create(AppModule, { logger: false });
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true, forbidNonWhitelisted: false }));
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it("register → 201 con access y refresh", async () => {
    const res = await request(app.getHttpServer())
      .post("/auth/register")
      .send({ email, password: "secreto123", displayName: "E2E User" });
    expect(res.status).toBe(201);
    expect(res.body.user.email).toBe(email);
    expect(res.body.user.plan).toBe("FREE");
    expect(res.body.accessToken).toBeTruthy();
    expect(res.body.refreshToken).toBeTruthy();
  });

  it("register duplicado → 409", async () => {
    const res = await request(app.getHttpServer())
      .post("/auth/register")
      .send({ email, password: "secreto123", displayName: "Otro" });
    expect(res.status).toBe(400);
    expect(res.body.code).toBe("EMAIL_TAKEN");
  });

  it("login con contraseña incorrecta → 401", async () => {
    const res = await request(app.getHttpServer())
      .post("/auth/login")
      .send({ email, password: "incorrecta1" });
    expect(res.status).toBe(401);
  });

  it("login correcto → 200 con tokens", async () => {
    const res = await request(app.getHttpServer())
      .post("/auth/login")
      .send({ email, password: "secreto123" });
    expect(res.status).toBe(200);
    expect(res.body.accessToken).toBeTruthy();
    expect(res.body.refreshToken).toBeTruthy();
  });

  it("GET /auth/me sin token → 401", async () => {
    const res = await request(app.getHttpServer()).get("/auth/me");
    expect(res.status).toBe(401);
  });

  it("GET /auth/me con token → id del usuario", async () => {
    const login = await request(app.getHttpServer())
      .post("/auth/login")
      .send({ email, password: "secreto123" });
    const res = await request(app.getHttpServer())
      .get("/auth/me")
      .set("Authorization", `Bearer ${login.body.accessToken}`);
    expect(res.status).toBe(200);
    expect(res.body.id).toBeTruthy();
  });

  it("refresh rota: el token viejo deja de servir", async () => {
    const login = await request(app.getHttpServer())
      .post("/auth/login")
      .send({ email, password: "secreto123" });
    const old = login.body.refreshToken;

    const refreshed = await request(app.getHttpServer())
      .post("/auth/refresh")
      .send({ refreshToken: old });
    expect(refreshed.status).toBe(200);
    expect(refreshed.body.refreshToken).not.toBe(old);

    const reuse = await request(app.getHttpServer()).post("/auth/refresh").send({ refreshToken: old });
    expect(reuse.status).toBe(401);
  });

  it("logout revoca el refresh token", async () => {
    const login = await request(app.getHttpServer())
      .post("/auth/login")
      .send({ email, password: "secreto123" });

    const out = await request(app.getHttpServer())
      .post("/auth/logout")
      .send({ refreshToken: login.body.refreshToken });
    expect(out.status).toBe(200);

    const after = await request(app.getHttpServer())
      .post("/auth/refresh")
      .send({ refreshToken: login.body.refreshToken });
    expect(after.status).toBe(401);
  });

  it("POST /chat con token: sin keys de IA configuradas → 502 legible", async () => {
    const login = await request(app.getHttpServer())
      .post("/auth/login")
      .send({ email, password: "secreto123" });
    const res = await request(app.getHttpServer())
      .post("/chat")
      .set("Authorization", `Bearer ${login.body.accessToken}`)
      .send({ text: "hola blu", tier: "light" });
    expect(res.status).toBe(503);
    expect(res.body.code).toBe("PROVIDER_NOT_CONFIGURED");
  });

  it("POST /chat sin token → 401", async () => {
    const res = await request(app.getHttpServer())
      .post("/chat")
      .send({ text: "hola blu", tier: "light" });
    expect(res.status).toBe(401);
  });

  it("valida el DTO: texto vacío → 400", async () => {
    const login = await request(app.getHttpServer())
      .post("/auth/login")
      .send({ email, password: "secreto123" });
    const res = await request(app.getHttpServer())
      .post("/chat")
      .set("Authorization", `Bearer ${login.body.accessToken}`)
      .send({ text: "", tier: "light" });
    expect(res.status).toBe(400);
  });
});