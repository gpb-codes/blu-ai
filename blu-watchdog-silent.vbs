Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\Users\MSI\.claude\scripts\blu-watchdog.ps1""", 0, False
