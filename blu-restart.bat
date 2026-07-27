@echo off
REM Reinicio robusto de Blu. Corre por fuera de node (lo lanza blu-restart.vbs),
REM asi sobrevive cuando se mata el proceso de Blu y lo relanza limpio.
REM 1) espera 5s para que Blu alcance a mandar su respuesta por WhatsApp
timeout /t 5 /nobreak >nul
REM 2) mata todos los node (Blu y sus hijos)
taskkill /IM node.exe /F >nul 2>&1
REM 3) espera a que liberen puertos
timeout /t 2 /nobreak >nul
REM 4) relanza Blu limpio via la tarea programada (elevada, carga el codigo actual)
schtasks /Run /TN "Blu-WhatsApp" >nul 2>&1
