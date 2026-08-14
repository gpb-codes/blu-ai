---
tipo: prompt
tags:
  - blu
  - plantilla
proveedor: ""
fecha: <% tp.date.now("YYYY-MM-DD") %>
---

# Prompt: <% tp.file.title %>

> **Copiar la sección del proveedor elegido, completar los `[...]` y pegar.**

---

## Antes de empezar (10 segundos)

1. ¿A quién se lo pedís?
   - **Claude** (chat/web/API): solo conversación — hay que **pegarle el contexto** (notas, código, errores).
   - **opencode** (CLI en tu repo): agente con acceso al repo — puede **leer y editar archivos** y correr comandos; basta indicarle las rutas.
2. Completá abajo: tarea, contexto, formato de respuesta.

---

## Prompt para CLAUDE

```
Actuá como asistente técnico del proyecto BLU (asistente IA con app web,
backend en Cloudflare Workers/D1 y repos en GitHub).

CONTEXTO (copiado de la bóveda):
- Qué estoy haciendo: [...]
- Antecedentes relevantes: [...]
- Notas/enlaces: [...]

TAREA:
[...]

RESTRICCIONES:
- Respuesta en español.
- [...] (ej: no inventar APIs, proponer alternativas, indicar riesgos)

FORMATO:
[...] (ej: pasos numerados, código completo, lista de decisiones)
```

---

## Prompt para OPENCODE

```
Proyecto: BLU IA — repo(s): [...]
Bóveda de contexto (marcdown): C:\Users\gabri\OneDrive\Desktop\trabajo\blu ai

Qué hacer:
[...]

Dónde mirar primero:
- [...] (rutas o archivos)

Reglas:
- Respuesta en español.
- No modifiques archivos sin que te lo pida; proponé primero el plan.
- [...]
```

---

## Después de la respuesta

- [ ] Guardar lo útil en la bóveda (`Blu AI - Bitacora`, notas del proyecto).
- [ ] Si generó código → revisarlo antes de commitear.
- [ ] Anotar el proveedor usado y qué funcionó mejor.

---

Relacionado: [[Blu AI - Tareas]] · [[Blu AI - Skills y mini-apps]]