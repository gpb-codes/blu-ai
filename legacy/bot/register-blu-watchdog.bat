@echo off
REM Registra la tarea Blu-Watchdog: revisa cada minuto si Blu sigue corriendo y lo revive si no.
REM Doble clic para ejecutar. Si pide permisos, acepta.

schtasks /Create /TN "Blu-Watchdog" ^
 /TR "powershell.exe -ExecutionPolicy Bypass -File \"C:\Users\MSI\.claude\scripts\blu-watchdog.ps1\"" ^
 /SC MINUTE /MO 1 /RL LIMITED /F

if %ERRORLEVEL%==0 (
  echo.
  echo Tarea Blu-Watchdog registrada correctamente.
) else (
  echo.
  echo Fallo el registro. Abre este .bat como administrador.
)
echo.
pause
