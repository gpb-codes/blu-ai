---
tags:
  - blu
  - equipo
  - setup
  - guia
tipo: guia
---

# Setup del equipo — accesos y dispositivos

> Guía para que todo el equipo (Gabriel, Pablo, Ignacio y marketing) tenga la bóveda funcionando en sus PCs y celulares.
> Repositorio: `gpb-codes/blu-ai` (privado) · Autorización necesaria: pedir acceso a **Gabriel**.

## Qué necesitas

| Herramienta | Para qué |
|---|---|
| **Obsidian** (gratis) | La app donde se leen/escriben las notas |
| **Git** | El motor de sincronización (viene explicado abajo) |
| **Acceso al repo** `gpb-codes/blu-ai` | Se lo pides a Gabriel (te invita como colaborador) |

## Cómo funciona la sincronización

Cada vez que editas, la bóveda se sincroniza sola contra GitHub (repo privado):

- Al **abrir** Obsidian: baja los cambios (pull) → siempre ves lo último.
- Cada **10 minutos**: guarda tus cambios (commit).
- Cada **30 minutos**: sube tus cambios (push) y baja los de los demás.

Regla práctica: si editas y **cierras rápido**, Obsidian guarda al cerrar si llevas 10 min. Para más seguridad, edita y espera unos segundos antes de cerrar.

---

## PC / Laptop (Windows)

1. Instala **Obsidian**: https://obsidian.md → *Download for Windows* → siguiente siguiente.
2. Instala **Git for Windows**: https://git-scm.com/download/win → instala con opciones por defecto.
3. Abre **PowerShell** y ejecuta:
   ```powershell
   gh auth login        # entra con tu cuenta de GitHub (la que Gabriel invite)
   gh repo clone gpb-codes/blu-ai
   ```
   > Si no tienes `gh` instalado, usa **GitHub Desktop** (https://desktop.github.com): File → Clone repository → `blu-ai`.
4. Abre **Obsidian** → *Abrir carpeta como bóveda* → selecciona la carpeta `blu-ai` descargada.
5. En Obsidian: *Ajustes → Complementos de la comunidad* → activa los complementos (primera vez pide confirmación). El plugin **Git** ya está instalado y activo.

✅ Listo: la bóveda se sincroniza sola.

## iPhone / iPad

1. Instala **Obsidian** y **Working Copy** (App Store, gratis).
2. Abre Working Copy → *Sign in* con tu cuenta de GitHub → *Clone repository* → `gpb-codes/blu-ai`.
3. En Obsidian: *Abrir carpeta como bóveda* → elige la carpeta clonada (dentro de Working Copy).
4. Para sincronizar: dentro de Obsidian usa el botón del plugin **Git** (commit/push/pull) o pulsa en Working Copy. Recomendado: cada vez que termines de editar, haz *push* desde Obsidian (barra de estado → icono de Git).

## Android

1. Instala **Obsidian** (Play Store) y **Termux** (F-Droid).
2. En Termux:
   ```
   pkg install git
   termux-setup-storage
   git clone https://github.com/gpb-codes/blu-ai /storage/shared/Obsidian/blu-ai
   ```
   (la primera vez te pedirá tu usuario/token de GitHub; si no sabes, pídeselo a Gabriel)
3. En Obsidian: *Abrir carpeta como bóveda* → `Obsidian/blu-ai`.
4. El plugin Git funciona desde Obsidian (commit/push/pull) usando el git de Termux.

---

## Solución de problemas

| Problema | Solución |
|---|---|
| "No se pueden cargar los cambios" | Comprueba que Git esté instalado (PC) o Working Copy/Termux (móvil) y que hayas entrado con tu GitHub |
| Archivo `* conflicto.md` | Alguien editó lo mismo a la vez: abre el archivo, combina a mano y borra el conflicto |
| No veo cambios de otros | Espera unos minutos (sincroniza cada 30) o haz pull manual con el botón Git |
| No me deja clonar (privado) | Aún no tienes acceso: pídeselo a Gabriel (repo `gpb-codes/blu-ai`) |

---

## Notas clave del proyecto

- [[Bienvenido]] — contexto del proyecto para el equipo
- [[Blu AI - Vision]] — índice de Blu AI
- [[Blu AI - Roadmap y estado]] — decisiones y hitos
- [[Blu AI - Gateway y Modelos]] — arquitectura de IA