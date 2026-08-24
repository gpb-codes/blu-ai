---
tags:
  - soybluia
  - web
  - extension
  - frontend
estado: planificacion
fase: Mes 1 (Web) / Meses 4-6 (Extensión)
fase_orden: 1
responsable: Pablo (frontend) · Ignacio (landing/contenido)
tipo: modulo
actualizacion: 24-ago-2026
---

# SoyBluAI — Web y Extensión Chrome

> Los dos frentes de frontal "ligero" de SoyBluAI: la web (Next.js) y la extensión de Chrome (MV3). Complementan la app Flutter y el CLI de SoyBluAI Code, y son los puntos de entrada más rápidos para el usuario.

## Web (Next.js 15)

Frontend principal basado en Next.js 15 (landing, pricing, login web, panel admin) + editor **SoyBluAI Code web** (Monaco + GitHub OAuth). Ver también [[SoyBluAI - Code]] y [[SoyBluAI - Stack tecnologico]].

- **Landing + waitlist:** hito de Mes 1 (agosto) — primera cara pública del producto.
- **Pricing y login web:** espejo de los planes de [[SoyBluAI - Planes y monetizacion]] y del auth del backend ([[SoyBluAI - Stack tecnologico]]).
- **Panel de usuario / admin:** gestión de cuenta, BYOK, créditos, proyectos.
- **SoyBluAI Code web:** editar y commitear código desde el navegador con GitHub conectado.
- **Estado real (fork auditado 17-ago-2026):** `apps/web` sigue en boilerplate default — sin diseño ni contenido propio; el diseño de frontend web está en cero (Pablo avanzado en Flutter, cero en web). Falta implementar la migración a Cloudflare D1 + Vectorize y el hosting definitivo (Vercel vs Cloudflare Workers/Pages).

## Extensión de Chrome (MV3)

Side panel que lleva SoyBluAI al navegador, donde el usuario ya trabaja. Fase Meses 4-6 del roadmap ([[SoyBluAI - Roadmap y estado]]).

- **Chat rápido:** preguntar a SoyBluAI sin salir de la pestaña.
- **Accesos a proyectos:** abrir/cambiar de proyecto desde el side panel.
- **Nota rápida a memoria:** enviar contexto a la [[SoyBluAI - Memoria compartida]] al vuelo.
- Es el puente natural hacia el módulo **Browser** (agente de navegador) y a las **Skills** ([[SoyBluAI - Skills y mini-apps]]).

## Diferenciador frente a los gigantes

ChatGPT/Claude/Gemini viven en su propia web o app cerrada. SoyBluAI apuesta por estar **donde el usuario ya está** (side panel del navegador + multi-dispositivo), con la misma memoria y gateway que el resto del ecosistema — no obliga a cambiar de pestaña.

## Estado y dependencias

- Web: depende del auth (JWT+refresh), BYOK encriptado y Stripe — todos en progreso/pendientes ([[Bienvenido]], sección 2; enlace corregido 24-ago-2026, apuntaba a un nombre de nota inexistente).
- Extensión: depende de la memoria compartida RAG y del gateway estables para ser útil.
- Ambos comparten el contrato Zod + OpenAPI del backend ([[SoyBluAI - Stack tecnologico]]).

Ver también: [[SoyBluAI - Vision]] (módulos), [[SoyBluAI - Roadmap y estado]], [[SoyBluAI - Chat]] (Model Router).
