@echo off
rem Double-click to install the After Effects MCP and skills for Claude Code (read-only mode).
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-For-Claude.ps1" %*
echo.
pause
