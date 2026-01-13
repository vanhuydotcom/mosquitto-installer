@echo off
REM Install MQTT Subscriber as a Scheduled Task that runs at startup
REM Run as Administrator

set INSTALL_DIR=%~1
if "%INSTALL_DIR%"=="" set INSTALL_DIR=C:\Program Files\Mosquitto

set TASK_NAME=MQTT-Subscriber
set VBS_PATH=%INSTALL_DIR%\scripts\start-subscriber-hidden.vbs

REM Delete existing task if exists
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1

REM Create scheduled task to run at system startup (with 30 sec delay to wait for Mosquitto)
schtasks /create /tn "%TASK_NAME%" /tr "wscript.exe \"%VBS_PATH%\" \"%INSTALL_DIR%\"" /sc onstart /delay 0000:30 /ru SYSTEM /rl HIGHEST /f

if %errorlevel% equ 0 (
    echo Subscriber task installed successfully
    echo Task will start automatically when system boots
    echo.
    echo To start manually: schtasks /run /tn "%TASK_NAME%"
    echo To stop: taskkill /f /im mosquitto_sub.exe
) else (
    echo Failed to install subscriber task
    exit /b 1
)

