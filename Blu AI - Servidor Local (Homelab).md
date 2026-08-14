---
tags:
  - blu
  - infra
  - homelab
  - seguridad
estado: borrador
fase: Mes 2 - Producto
responsable: Gabriel
tipo: infra
---

# Blu AI — Servidor local (Homelab híbrido)

> Decisiones de infraestructura para alojar los componentes de Blu AI en un equipo
> propio (Windows) y compartirlo con el equipo, sin rehacer el backend por temas
> legales/seguridad después.

## Decisión: arquitectura híbrida

El hardware disponible (CPU sin VRAM útil para IA, ~16 GB RAM, pocos núcleos) **no**
soporta servir modelos de IA a un equipo completo de forma local. Por eso:

- **Esta máquina = orquestador + gateway + dev/staging + share de archivos.**
- **La IA pesada (LLM grandes, generación de imágenes) corre en GPU en la nube**
  (RunPod / Vast.ai / VM) y se enruta vía gateway.
- **Modelos locales ligeros solo para test/dev** (p. ej. `qwen2.5:1.5b`,
  `nomic-embed-text` para embeddings — esto sí corre bien en CPU).

Esto resuelve "compartir con equipo" + "backend + webapps + DBs + IA + archivos"
sin prometer inferencia local imposible, y deja definida la residencia de datos
para el doc de cumplimiento.

## Topología

```
 Equipo Blu AI
   │  (Tailscale mesh VPN — sin puertos abiertos)
   ▼
 SERVER (Windows + WSL2 Ubuntu + Docker)
   ├─ Caddy (reverse proxy + TLS)
   ├─ LiteLLM gateway  ──► modelo local ligero (test)
   │                    └─► Claude / Kimi (externos)
   │                    └─► nodo GPU nube (carga real)
   ├─ Backend / APIs (contenedor)
   ├─ Postgres + Redis (contenedores)
   ├─ Webapps (contenedores)
   └─ Syncthing / share (vault + archivos)
```

## Componentes

| Capa | Herramienta | Nota |
|------|-------------|------|
| SO host | Windows 10/11 | Si es Win10: solo Tailscale, cero puertos, Defender on |
| Linux | WSL2 + Ubuntu | systemd habilitado |
| Contenedores | Docker Desktop (WSL2 backend) | `.wslconfig` limita RAM/CPU |
| Gateway IA | LiteLLM | une local + externos + nube |
| Datos | Postgres, Redis | volúmenes persistidos fuera de WSL |
| Proxy | Caddy | TLS automático por dominio Tailscale |
| Acceso | Tailscale | mesh VPN, ACLs por persona |
| Archivos | Syncthing | sync del vault entre equipos |

## Setup en el server (PowerShell como Administrador)

```powershell
# 1) WSL2 + Ubuntu (Win10/11)
wsl --install -d Ubuntu

# 2) Docker Desktop: instalar si no está
winget install -e --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements

# 3) Tailscale (mesh VPN)
winget install -e --id Tailscale.Tailscale --accept-package-agreements --accept-source-agreements
```

Después de reiniciar, pasos **interactivos**:

```powershell
# Primera ejecución de Ubuntu: crear usuario UNIX (pedirá usuario/contraseña)
ubuntu

# Dentro de Ubuntu, habilitar systemd (si no está) y arrancar Docker
echo -e "[boot]\nsystemd=true" | sudo tee -a /etc/wsl.conf
# Reiniciar WSL desde PowerShell:
wsl --shutdown

# Loguear Tailscale (abre navegador)
tailscale up
```

## .wslconfig (en %USERPROFILE%\.wslconfig, en el host Windows)

```ini
[wsl2]
memory=10GB
processors=4
localhostForwarding=true
```

## Verificación

```powershell
wsl -d Ubuntu -e docker run --rm hello-world
wsl -d Ubuntu -e docker compose version
tailscale status
```

## Seguridad

- Win10 fuera de soporte: mitigar con Tailscale-only, sin exponer puertos, Defender activo.
- Secretos en `.env` no versionados; nunca en el vault.
- Backups de volúmenes Docker (Postgres) a disco externo / nube.
- ACLs de Tailscale por persona del equipo.

## Pendientes

- [ ] Definir nodo GPU en la nube y credenciales del gateway.
- [ ] Decidir dominio/TLS para Caddy sobre Tailscale.
- [ ] Cerrar residencia de datos en doc de cumplimiento (ver `Blu AI - Cumplimiento y Seguridad.md`).
