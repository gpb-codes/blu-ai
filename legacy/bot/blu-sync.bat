@echo off
cd /d "%USERPROFILE%\.claude\projects\blu-memory"
git pull --rebase --autostash origin main >nul 2>&1
git add -A
git commit -q -m "auto-sync %date% %time%" >nul 2>&1
git push -q origin main >nul 2>&1
