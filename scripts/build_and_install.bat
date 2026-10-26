@echo off
setlocal
echo === Apple TV Launcher Build and Install ===
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_and_install.ps1"
pause
