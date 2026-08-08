# Correr como Administrador
Write-Host "Matando todos los procesos Python..." -ForegroundColor Yellow
taskkill /IM python.exe /F 2>$null
taskkill /IM python3.exe /F 2>$null
Start-Sleep -Seconds 1

$still = netstat -ano | findstr ":5051"
if ($still) {
    Write-Host "ADVERTENCIA: Puerto 5051 sigue ocupado:" -ForegroundColor Red
    Write-Host $still
} else {
    Write-Host "Puerto 5051 libre." -ForegroundColor Green
}

Write-Host "Iniciando Blu server..." -ForegroundColor Cyan
python "C:\Users\MSI\.claude\scripts\blu-server.py"
