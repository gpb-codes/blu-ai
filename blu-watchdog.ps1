# blu-watchdog.ps1 — revisa que blu-whatsapp.js siga corriendo, lo revive si se cayo
# Se ejecuta cada minuto via Tarea Programada "Blu-Watchdog" (registrada por el usuario)

$scriptPath = "C:\Users\MSI\.claude\scripts\blu-whatsapp.js"
$logFile    = "C:\Users\MSI\.claude\scripts\blu-watchdog.log"

function Write-Log($msg) {
  $t = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Add-Content -Path $logFile -Value "[$t] $msg"
}

$running = Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue |
  Where-Object { $_.CommandLine -like "*blu-whatsapp.js*" }

if (-not $running) {
  Write-Log "Blu no esta corriendo. Reiniciando..."
  Start-Process -FilePath "node" -ArgumentList "`"$scriptPath`"" -WindowStyle Hidden
  Write-Log "Blu reiniciado."
}
