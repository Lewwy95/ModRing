@echo off
setlocal

:: Create 'Temp' Directory
if not exist "%~dp0\bin\Temp" mkdir "%~dp0\bin\Temp"

:: Set Current Version Number
set /p current=<version.txt

:: Get Latest Version File
echo Comparing versions...
type NUL > "%~dp0\bin\Temp\version_new.txt"
powershell -c "(Invoke-WebRequest -URI 'https://raw.githubusercontent.com/Lewwy95/ModRing/main/version.txt').Content | Set-Content -Path '%~dp0\bin\Temp\version_new.txt'"
cls

:: Set Latest Version Number
set /p new=<"%~dp0\bin\Temp\version_new.txt"

:: Print Version Information
echo Checking for updates...
echo.
echo Current: v%current%
echo Latest: v%new%
timeout /t 2 /nobreak >nul
cls

:: Clear New Version File
del /s /q "%~dp0\bin\Temp\version_new.txt"
cls

:: Check For Different Version Files
if %new% neq %current% (
    echo Update required! Installing...
    timeout /t 2 /nobreak >nul
    cls
    goto install
)

:: Check For Install
if exist "%~dp0..\ModEngine" goto launch

:: Not Installed
echo ModRing is not installed! Installing...
timeout /t 2 /nobreak >nul
cls
goto install

:: Installation/Updater
:install
echo Downloading latest revision...
powershell -c "(New-Object System.Net.WebClient).DownloadFile('https://github.com/Lewwy95/ModRing/archive/refs/heads/main.zip','%~dp0\bin\Temp\ModRing-main.zip')"
cls

:: Extract Latest Revision
echo Extracting latest revision...
powershell -c "Expand-Archive '%~dp0\bin\Temp\ModRing-main.zip' -Force '%~dp0\bin\Temp'"
cls

:: Deploy Latest Revision
echo Deploying latest revision...
xcopy /s /y "%~dp0\bin\Temp\ModRing-main" "%~dp0"
cls

:: Apply New Version File
break>version.txt
powershell -c "(Invoke-WebRequest -URI 'https://raw.githubusercontent.com/Lewwy95/ModRing/main/version.txt').Content | Set-Content -Path '%~dp0\version.txt'"
cls

:: Uninstall All Mods
call "%~dp0\Uninstall.bat"

:: Move New Mods
echo Installing mods...
timeout /t 2 /nobreak >nul
if not exist "%~dp0..\SeamlessCoop" mkdir "%~dp0..\SeamlessCoop"
copy "%~dp0\bin\SeamlessCoop\launch_elden_ring_seamlesscoop.exe" "%~dp0..\"
xcopy /s /y "%~dp0\bin\SeamlessCoop\SeamlessCoop\*" "%~dp0..\SeamlessCoop"
if not exist "%~dp0..\ModEngine" mkdir "%~dp0..\ModEngine"
if not exist "%~dp0..\ModEngine\mod" mkdir "%~dp0..\ModEngine\mod"
if not exist "%~dp0..\ModEngine\modengine2" mkdir "%~dp0..\ModEngine\modengine2"
xcopy /s /y "%~dp0\bin\ModEngine\*" "%~dp0..\ModEngine"
if not exist "%~dp0..\mods" mkdir "%~dp0..\mods"
if not exist "%~dp0..\mods\IncreaseAnimationDistance" mkdir "%~dp0..\mods\IncreaseAnimationDistance"
if not exist "%~dp0..\mods\RemoveVignette" mkdir "%~dp0..\mods\RemoveVignette"
if not exist "%~dp0..\mods\SkipTheIntro" mkdir "%~dp0..\mods\SkipTheIntro"
if not exist "%~dp0..\mods\UltrawideFix" mkdir "%~dp0..\mods\UltrawideFix"
if not exist "%~dp0..\mods\UnlockTheFps" mkdir "%~dp0..\mods\UnlockTheFps"
copy "%~dp0\bin\ModLoader\dinput8.dll" "%~dp0..\"
copy "%~dp0\bin\ModLoader\mod_loader_config.ini" "%~dp0..\"
xcopy /s /y "%~dp0\bin\ModLoader\Mods\*" "%~dp0..\mods"
cls

:: Widescreen Checker
powershell.exe Get-WmiObject win32_videocontroller | find "CurrentHorizontalResolution" > resChecker.txt
powershell.exe Get-WmiObject win32_videocontroller | find "CurrentVerticalResolution" >> resChecker.txt
for /f "tokens=1-2 delims=^:^ " %%a in (resChecker.txt) do set %%a=%%b
if %CurrentHorizontalResolution% neq 3440 goto nowide

:: Clean Up
:cleanup
echo Cleaning up...
del /s /q "%~dp0\bin\Temp\*"
rmdir /s /q "%~dp0\bin\Temp"
mkdir "%~dp0\bin\Temp"
del "%~dp0\resChecker.txt"
cls

:: Launch Game
:launch
echo Launching ModRing...
timeout /t 2 /nobreak >nul
cd "%~dp0..\ModEngine"
call "%~dp0..\ModEngine\launchmod_eldenring.bat"
goto end

:: No Widescreen
:nowide
rmdir /s /q "%~dp0..\ModEngine\mod\menu\win"
del /s /q "%~dp0..\ModEngine\mod\menu\*.gfx"
rmdir /s /q "%~dp0..\mods\UltrawideFix"
del /s /q "%~dp0..\mods\UltrawideFix.dll"
goto cleanup

:: Finish
:end
endlocal
