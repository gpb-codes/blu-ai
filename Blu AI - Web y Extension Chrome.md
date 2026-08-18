---
tags:
  - blu
  - web
  - extension
  - frontend
estado: planificacion
fase: Mes 1 (Web) / Meses 4-6 (Extensión)
responsable: Pablo (frontend) · Ignacio (landing/contenido)
tipo: modulo
---

# Blu AI — Web y Extensión Chrome

> Los dos frentes de frontal "ligero" de Blu: la web (Next.js) y la extensión de Chrome (MV3). Complementan la app Flutter y el CLI de Blu Code, y son los puntos de entrada más rápidos para el usuario.

## Web (Next.js 15)

Frontend principal basado en Next.js 15 (landing, pricing, login web, panel admin) + editor **Blu Code web** (Monaco + GitHub OAuth). Ver también [[Blu AI - Blu Code]] y [[Blu AI - Stack tecnologico]].

- **Landing + waitlist:** hito de Mes 1 (agosto) — primera cara pública del producto.
- **Pricing y login web:** espejo de los planes de [[Blu AI - Planes y monetizacion]] y del auth del backend ([[Blu AI - Stack tecnologico]]).
- **Panel de usuario / admin:** gestión de cuenta, BYOK, créditos, proyectos.
- **Blu Code web:** editar y commitear código desde el navegador con GitHub conectado.
- **Estado real (fork auditado 17-ago-2026):** `apps/web` sigue en boilerplate default — sin diseño ni contenido propio; el diseño de frontend web está en cero (Pablo avanzado en Flutter, cero en web). Falta implementar la migración a Cloudflare D1 + Vectorize y el hosting definitivo (Vercel vs Cloudflare Workers/Pages).

## Extensión de Chrome (MV3)

Side panel que lleva Blu al navegador, donde el usuario ya trabaja. Fase Meses 4-6 del roadmap ([[Blu AI - Roadmap y estado]]).

- **Chat rápido:** preguntar a Blu sin salir de la pestaña.
- **Accesos a proyectos:** abrir/cambiar de proyecto desde el side panel.
- **Nota rápida a memoria:** enviar contexto a la [[Blu AI - Memoria compartida]] al vuelo.
- Es el puente natural hacia el módulo **Browser** (agente de navegador) y a las **Skills** ([[Blu AI - Skills y mini-apps]]).

## Diferenciador frente a los gigantes

ChatGPT/Claude/Gemini viven en su propia web o app cerrada. Blu apuesta por estar **donde el usuario ya está** (side panel del navegador + multi-dispositivo), con la misma memoria y gateway que el resto del ecosistema — no obliga a cambiar de pestaña.

## Estado y dependencias

- Web: depende del auth (JWT+refresh), BYOK encriptado y Stripe — todos en progreso/pendientes ([[Blu AI - Bienvenido]], sección 2).
- Extensión: depende de la memoria compartida RAG y del gateway estables para ser útil.
- Ambos comparten el contrato Zod + OpenAPI del backend ([[Blu AI - Stack tecnologico]]).

Ver también: [[Blu AI - Vision]] (módulos), [[Blu AI - Roadmap y estado]], [[Blu AI - Blu Chat]] (Model Router).
