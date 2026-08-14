---
tags:
  - blu
  - equipo
  - setup
  - guia
tipo: guia
---

# Setup del equipo â€” accesos y dispositivos

> GuÃ­a para que todo el equipo (Gabriel, Pablo, Ignacio y marketing) tenga la bÃ³veda funcionando en sus PCs y celulares.
> Repositorio: `gpb-codes/blu-ai` (privado) Â· AutorizaciÃ³n necesaria: pedir acceso a **Gabriel**.

## QuÃ© necesitas

| Herramienta | Para quÃ© |
|---|---|
| **Obsidian** (gratis) | La app donde se leen/escriben las notas |
| **Git** | El motor de sincronizaciÃ³n (viene explicado abajo) |
| **Acceso al repo** `gpb-codes/blu-ai` | Se lo pides a Gabriel (te invita como colaborador) |

## CÃ³mo funciona la sincronizaciÃ³n

Cada vez que editas, la bÃ³veda se sincroniza sola contra GitHub (repo privado):

- Al **abrir** Obsidian: baja los cambios (pull) â†’ siempre ves lo Ãºltimo.
- Cada **10 minutos**: guarda tus cambios (commit).
- Cada **30 minutos**: sube tus cambios (push) y baja los de los demÃ¡s.

Regla prÃ¡ctica: si editas y **cierras rÃ¡pido**, Obsidian guarda al cerrar si llevas 10 min. Para mÃ¡s seguridad, edita y espera unos segundos antes de cerrar.

---

## PC / Laptop (Windows)

1. Instala **Obsidian**: https://obsidian.md â†’ *Download for Windows* â†’ siguiente siguiente.
2. Instala **Git for Windows**: https://git-scm.com/download/win â†’ instala con opciones por defecto.
3. Abre **PowerShell** y ejecuta:
   ```powershell
   gh auth login        # entra con tu cuenta de GitHub (la que Gabriel invite)
   gh repo clone gpb-codes/blu-ai
   ```
   > Si no tienes `gh` instalado, usa **GitHub Desktop** (https://desktop.github.com): File â†’ Clone repository â†’ `blu-ai`.
4. Abre **Obsidian** â†’ *Abrir carpeta como bÃ³veda* â†’ selecciona la carpeta `blu-ai` descargada.
5. En Obsidian: *Ajustes â†’ Complementos de la comunidad* â†’ activa los complementos (primera vez pide confirmaciÃ³n). El plugin **Git** ya estÃ¡ instalado y activo.

âœ… Listo: la bÃ³veda se sincroniza sola.

## iPhone / iPad

1. Instala **Obsidian** y **Working Copy** (App Store, gratis).
2. Abre Working Copy â†’ *Sign in* con tu cuenta de GitHub â†’ *Clone repository* â†’ `gpb-codes/blu-ai`.
3. En Obsidian: *Abrir carpeta como bÃ³veda* â†’ elige la carpeta clonada (dentro de Working Copy).
4. Para sincronizar: dentro de Obsidian usa el botÃ³n del plugin **Git** (commit/push/pull) o pulsa en Working Copy. Recomendado: cada vez que termines de editar, haz *push* desde Obsidian (barra de estado â†’ icono de Git).

## Android

1. Instala **Obsidian** (Play Store) y **Termux** (F-Droid).
2. En Termux:
   ```
   pkg install git
   termux-setup-storage
   git clone https://github.com/gpb-codes/blu-ai /storage/shared/Obsidian/blu-ai
   ```
   (la primera vez te pedirÃ¡ tu usuario/token de GitHub; si no sabes, pÃ­deselo a Gabriel)
3. En Obsidian: *Abrir carpeta como bÃ³veda* â†’ `Obsidian/blu-ai`.
4. El plugin Git funciona desde Obsidian (commit/push/pull) usando el git de Termux.

---

## SoluciÃ³n de problemas

| Problema | SoluciÃ³n |
|---|---|
| "No se pueden cargar los cambios" | Comprueba que Git estÃ© instalado (PC) o Working Copy/Termux (mÃ³vil) y que hayas entrado con tu GitHub |
| Archivo `* conflicto.md` | Alguien editÃ³ lo mismo a la vez: abre el archivo, combina a mano y borra el conflicto |
| No veo cambios de otros | Espera unos minutos (sincroniza cada 30) o haz pull manual con el botÃ³n Git |
| No me deja clonar (privado) | AÃºn no tienes acceso: pÃ­deselo a Gabriel (repo `gpb-codes/blu-ai`) |

---

## Notas clave del proyecto

- [[Bienvenido]] â€” contexto del proyecto para el equipo
- [[Blu AI - Vision]] â€” Ã­ndice de Blu AI
- [[Blu AI - Roadmap y estado]] â€” decisiones y hitos
- [[Blu AI - Gateway y Modelos]] â€” arquitectura de IA
