@echo off
REM Registra la tarea programada Blu-WhatsApp (arranca el bot al iniciar sesion).
REM Doble clic para ejecutar. Si pide permisos, acepta.

schtasks /Create /TN "Blu-WhatsApp" ^
 /TR "\"C:\Program Files\nodejs\node.exe\" \"C:\Users\MSI\.claude\scripts\blu-whatsapp.js\"" ^
 /SC ONLOGON /RL LIMITED /F

if %ERRORLEVEL%==0 (
  echo.
  echo Tarea Blu-WhatsApp registrada correctamente.
) else (
  echo.
  echo Fallo el registro. Abre este .bat como administrador.
)
echo.
pause
