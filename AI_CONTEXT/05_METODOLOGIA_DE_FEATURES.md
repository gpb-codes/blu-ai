# Metodología para implementar features

Este documento define cómo debe trabajar una IA cuando el usuario pide implementar una funcionalidad.

## Principio
**Entender → inspeccionar → diseñar → implementar → validar → documentar.**

No empezar escribiendo código sin entender el sistema existente.

## 1. Definir el feature
Antes de tocar código, producir mentalmente o explícitamente:
- problema;
- usuario/actor;
- resultado esperado;
- alcance incluido;
- alcance fuera del feature;
- criterios de aceptación;
- dependencias;
- riesgos.

Si el feature es ambiguo, hacer una pregunta concreta o proponer una interpretación razonable y marcarla.

## 2. Trazar el sistema existente
Buscar primero:
- rutas/API;
- controllers/services/modules;
- schemas/types;
- componentes UI;
- hooks/utilidades;
- adapters del gateway;
- memoria/RAG;
- auth/permisos;
- tests;
- configuración/env;
- documentación y ADRs relacionados.

El objetivo es extender el sistema, no crear un segundo sistema paralelo.

## 3. Diseñar la mínima solución correcta
La solución debe:
- encajar en la arquitectura actual;
- reutilizar patrones existentes;
- mantener separación de responsabilidades;
- evitar dependencias nuevas salvo justificación;
- considerar seguridad, coste y observabilidad;
- ser reversible cuando sea posible.

Para features de IA, considerar además:
- proveedor/modelo;
- fallback;
- límites de coste;
- privacidad;
- contexto/memoria;
- tool use;
- streaming;
- errores y timeouts.

## 4. Backend primero cuando exista contrato
Cuando el feature cruza frontend/backend:
1. definir/ajustar contrato;
2. validar datos con schemas;
3. implementar lógica de dominio;
4. añadir tests;
5. integrar UI.

No duplicar reglas de negocio en varios clientes.

## 5. Features de agentes
Para cualquier agente que pueda actuar:
- definir capabilities;
- definir permisos;
- definir límites;
- definir herramientas permitidas;
- definir qué requiere aprobación humana;
- definir qué ocurre ante error/reintento;
- evitar acciones irreversibles sin control.

## 6. Features multi-modelo
No acoplar el feature a un único proveedor si el gateway permite abstracción común.

Si una capability depende de un modelo concreto, documentar:
- por qué;
- fallback;
- impacto de coste;
- impacto de privacidad;
- comportamiento si el proveedor no está disponible.

## 7. Testing
Como mínimo, según el cambio:
- unit tests para lógica nueva;
- tests de integración para contratos/API;
- tests de gateway cuando haya routing/adapters;
- typecheck/lint/build relevantes;
- pruebas de errores y edge cases.

No aceptar "funciona" como sustituto de validación.

## 8. UX
Un feature no está terminado solo porque el backend funcione.

Comprobar:
- loading/streaming;
- errores legibles;
- estados vacíos;
- permisos;
- responsive/multiplataforma cuando aplique;
- feedback al usuario;
- accesibilidad razonable.

## 9. Documentación
Actualizar solo lo necesario:
- documentación del módulo;
- ADR si hubo una decisión arquitectónica;
- roadmap/tarea si cambia el estado;
- AI_CONTEXT si se descubrió una nueva regla de trabajo.

## 10. Resultado esperado de una implementación
Al finalizar, la IA debe poder resumir:
- qué cambió;
- qué archivos/módulos se tocaron;
- por qué se eligió esa solución;
- qué tests se ejecutaron y resultado;
- riesgos o pendientes;
- cómo probar el feature manualmente.

## Anti-patrones
Evitar:
- sobreingeniería;
- refactors no relacionados;
- cambios masivos sin necesidad;
- inventar APIs;
- duplicar lógica;
- introducir un framework nuevo por preferencia personal;
- ocultar fallos de tests;
- marcar como terminado algo que solo está parcialmente implementado.