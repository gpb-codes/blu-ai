@echo off
REM Registra Blu-Server, Blu-WhatsApp y Blu-Watchdog para arrancar
REM apenas prende la PC (ONSTART), corriendo como SYSTEM, sin necesitar
REM login ni desbloqueo. Debe ejecutarse como Administrador.

schtasks /Create /TN "Blu-Server" ^
 /TR "\"C:\Users\MSI\AppData\Local\Programs\Python\Python311\python.exe\" \"C:\Users\MSI\.claude\scripts\blu-server.py\"" ^
 /SC ONSTART /RU SYSTEM /RL HIGHEST /F

schtasks /Create /TN "Blu-WhatsApp" ^
 /TR "\"C:\Program Files\nodejs\node.exe\" \"C:\Users\MSI\.claude\scripts\blu-whatsapp.js\"" ^
 /SC ONSTART /RU SYSTEM /RL HIGHEST /F

schtasks /Create /TN "Blu-Watchdog" ^
 /TR "powershell.exe -ExecutionPolicy Bypass -File \"C:\Users\MSI\.claude\scripts\blu-watchdog.ps1\"" ^
 /SC MINUTE /MO 1 /RU SYSTEM /RL HIGHEST /F

echo.
echo Listo. Las 3 tareas quedaron registradas para arrancar con el sistema (SYSTEM, ONSTART).
echo Puedes verificarlas en el Programador de tareas o con: schtasks /Query /TN "Blu-Server"
echo.
pause
