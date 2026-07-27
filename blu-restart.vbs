' Lanzador invisible del reinicio de Blu. Corre fuera de node, sobrevive al taskkill.
Set objShell = CreateObject("WScript.Shell")
objShell.Run "cmd /c C:\Users\MSI\.claude\scripts\blu-restart.bat", 0, False
