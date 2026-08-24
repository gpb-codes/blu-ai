# Borra los archivos con nombre antiguo ("Blu AI - X.md" / "Templates\BLU - X.md")
# que quedaron huerfanos despues del rebranding a SoyBluAI (24-ago-2026).
# Esta sesion de Claude no tiene permiso para borrar archivos en tu computadora,
# por eso este script te lo genera para que lo corras vos.
#
# Uso:
#   1. Abri PowerShell en la carpeta de la boveda (o dejá que el script la detecte).
#   2. Ejecutá:  .\limpiar-archivos-viejos.ps1
#      (si PowerShell bloquea el script: click derecho -> Propiedades -> Desbloquear,
#      o corré antes: Unblock-File .\limpiar-archivos-viejos.ps1)
#   3. El script pide confirmacion antes de borrar cada tanda.

$ErrorActionPreference = "Stop"
$vault = "C:\Users\gabri\OneDrive\Desktop\blu-ai"

$archivosRaiz = @(
  "Blu AI - Agent Builder y Marketplace.md",
  "Blu AI - Agentes.md",
  "Blu AI - Bitacora.md",
  "Blu AI - Blu Chat.md",
  "Blu AI - Blu Code.md",
  "Blu AI - Clientes ideales.md",
  "Blu AI - Conectores, MCP y Assets.md",
  "Blu AI - Cumplimiento y Seguridad.md",
  "Blu AI - Datasets - Catalogo.md",
  "Blu AI - Datasets y Personalizacion.md",
  "Blu AI - Decisiones (ADRs).md",
  "Blu AI - Gateway y Modelos.md",
  "Blu AI - Kanban.md",
  "Blu AI - Memoria compartida.md",
  "Blu AI - Metricas semanales.md",
  "Blu AI - Planes y monetizacion.md",
  "Blu AI - Roadmap y estado.md",
  "Blu AI - Skills y mini-apps.md",
  "Blu AI - SOUP y AI Core.md",
  "Blu AI - Stack tecnologico.md",
  "Blu AI - Studios y Mission Mode.md",
  "Blu AI - Tareas.md",
  "Blu AI - Vision.md",
  "Blu AI - Web y Extension Chrome.md",
  "Blu AI - Workflow Builder y Automatizacion.md"
)

$archivosTemplates = @(
  "Templates\BLU - Nota de proyecto.md",
  "Templates\BLU - Prompt IA.md",
  "Templates\BLU - Tarea.md"
)

Write-Host "Boveda: $vault"
Write-Host ""
Write-Host "Se van a borrar $($archivosRaiz.Count + $archivosTemplates.Count) archivos con nombre antiguo:"
$archivosRaiz + $archivosTemplates | ForEach-Object { Write-Host "  - $_" }
Write-Host ""
$confirm = Read-Host "Confirmar borrado? (escribi SI para continuar)"
if ($confirm -ne "SI") {
  Write-Host "Cancelado. No se borro nada."
  exit
}

$borrados = 0
$noEncontrados = 0
foreach ($rel in ($archivosRaiz + $archivosTemplates)) {
  $full = Join-Path $vault $rel
  if (Test-Path -LiteralPath $full) {
    Remove-Item -LiteralPath $full -Force
    Write-Host "Borrado: $rel"
    $borrados++
  } else {
    Write-Host "No encontrado (ya borrado?): $rel"
    $noEncontrados++
  }
}

Write-Host ""
Write-Host "Listo. Borrados: $borrados. No encontrados: $noEncontrados."
Write-Host "El plugin Git de Obsidian va a detectar los borrados en el proximo auto-commit (hasta 10 min),"
Write-Host "o podes forzarlo ahora: en Obsidian, Ctrl+P -> 'Git: Commit and push'."
