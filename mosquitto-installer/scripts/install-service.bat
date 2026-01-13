@echo off
REM Install Mosquitto as Windows Service with correct config path
REM Usage: install-service.bat "C:\Program Files\Mosquitto"

set INSTALL_DIR=%~1

REM Delete existing service if exists
sc query mosquitto >nul 2>&1
if %errorlevel% equ 0 (
    net stop mosquitto >nul 2>&1
    sc delete mosquitto >nul 2>&1
    timeout /t 2 /nobreak >nul
)

REM Create service with correct binPath
sc create mosquitto binPath= "\"%INSTALL_DIR%\bin\mosquitto.exe\" -c \"%INSTALL_DIR%\conf\mosquitto.conf\"" DisplayName= "Mosquitto Broker" start= demand

if %errorlevel% equ 0 (
    echo Service installed successfully
) else (
    echo Failed to install service
    exit /b 1
)

