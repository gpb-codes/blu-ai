@echo off
echo Registrando Blu-WhatsApp...
schtasks /Create /TN "Blu-WhatsApp" /TR "C:\Users\MSI\.claude\scripts\run-blu-whatsapp.bat" /SC ONSTART /RU SYSTEM /RL HIGHEST /F
echo Resultado Blu-WhatsApp: %ERRORLEVEL%
echo.

echo Registrando Blu-Watchdog...
schtasks /Create /TN "Blu-Watchdog" /TR "powershell.exe -ExecutionPolicy Bypass -File \"C:\Users\MSI\.claude\scripts\blu-watchdog.ps1\"" /SC MINUTE /MO 1 /RU SYSTEM /RL HIGHEST /F
echo Resultado Blu-Watchdog: %ERRORLEVEL%
echo.

echo ============================================
echo Si alguno dice "Resultado: 1" o distinto de 0, copia TODO el texto
echo de arriba (incluyendo cualquier mensaje de Windows Defender) y
echo muestraselo a Claude.
echo ============================================
pause
