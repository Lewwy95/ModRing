@echo off
setlocal

:: Uninstall All Mods
echo Uninstalling current mods...
timeout /t 2 /nobreak >nul

:: Delete All Mods
if exist "%~dp0..\mods" rmdir /s /q "%~dp0..\mods"
if exist "%~dp0..\ModEngine" rmdir /s /q "%~dp0..\ModEngine"
if exist "%~dp0..\SeamlessCoop" rmdir /s /q "%~dp0..\SeamlessCoop"
if exist "%~dp0..\dinput8.dll" del /s /q "%~dp0..\dinput8.dll"
if exist "%~dp0..\mod_loader_config.ini" del /s /q "%~dp0..\mod_loader_config.ini"
if exist "%~dp0..\mod_loader_log.txt" del /s /q "%~dp0..\mod_loader_log.txt"
if exist "%~dp0..\launch_elden_ring_seamlesscoop.exe" del /s /q "%~dp0..\launch_elden_ring_seamlesscoop.exe"
cls

:: Finish
endlocal
