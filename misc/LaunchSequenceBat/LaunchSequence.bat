@echo off

cd /d %~dp0%
cd ..

ECHO Working in directory: %CD%
ECHO Blocking mouse movement
start "" "ahk/disableMouse.ahk"

REM --- Start XAMPP services (Apache & MySQL) ---
timeout /t 2 /nobreak >nul
@REM start "" "C:\xampp\apache_start.bat"
@REM start "" "C:\xampp\mysql_start.bat"

timeout /t 10 /nobreak >nul

REM --- Determine the correct base URL ---
IF EXIST "C:\xampp\htdocs\maniek\praktyki-maniek" (
    SET "BASE_URL=http://localhost/maniek/praktyki-maniek"
) ELSE IF EXIST "C:\xampp\htdocs\Praktyki-Maniek" (
    SET "BASE_URL=http://localhost/Praktyki-Maniek"
) ELSE (
    ECHO Error: Neither "maniek\praktyki-maniek" nor "Praktyki-Maniek" directories found in htdocs.
    EXIT /B 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File launchBrowser.ps1 ^
    -BaseUrl "%BASE_URL%"

REM --- Start the AutoHotkey script to focus the windows ---
start "" "ahk/focusManiekWindow.ahk"

timeout /t 5 /nobreak >nul
taskkill /IM AutoHotKey64.exe

cmd /k