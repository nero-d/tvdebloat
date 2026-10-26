@echo off
setlocal
echo === TV Debloat Restoration ===
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0restore.ps1"
pause
