@echo off
REM Bleak Faith: Forsaken JP localization - deploy launcher
REM Double-click to deploy BleakFaithForsaken_JP_P.pak to the Steam install.
REM deploy.ps1 self-elevates if needed.
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy.ps1"
echo.
pause
