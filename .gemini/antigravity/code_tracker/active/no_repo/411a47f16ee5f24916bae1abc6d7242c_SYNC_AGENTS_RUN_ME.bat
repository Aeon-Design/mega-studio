•@echo off
title Antigravity Mega Studio Sync
color 0A
cls

echo ========================================================
echo   ANTIGRAVITY MEGA STUDIO - AUTO SYNC SERVICE
echo ========================================================
echo.
echo  [1] Finding Projects...
echo  [2] removing Legacy Agents...
echo  [3] Deploying 24-Agent Dream Team...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Abdullah\AutoSync-MegaStudio.ps1"

echo.
echo ========================================================
echo   SYNC COMPLETE! All projects updated.
echo ========================================================
echo.
pause
•*cascade0820file:///C:/Users/Abdullah/SYNC_AGENTS_RUN_ME.bat