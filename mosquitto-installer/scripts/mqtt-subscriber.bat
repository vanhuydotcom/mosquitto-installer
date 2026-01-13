@echo off
REM MQTT Auto Subscriber - Subscribes to reader topics and logs to file
REM Runs in background when Mosquitto service starts

set INSTALL_DIR=%~1
if "%INSTALL_DIR%"=="" set INSTALL_DIR=C:\Program Files\Mosquitto

set LOG_FILE=%INSTALL_DIR%\logs\mqtt-subscriber.log
set TOPIC=reader/#

echo [%date% %time%] Starting MQTT Subscriber for topic: %TOPIC% >> "%LOG_FILE%"

:retry
"%INSTALL_DIR%\bin\mosquitto_sub.exe" -h localhost -p 1883 -t "%TOPIC%" -v >> "%LOG_FILE%" 2>&1

echo [%date% %time%] Subscriber disconnected. Retrying in 5 seconds... >> "%LOG_FILE%"
timeout /t 5 /nobreak >nul
goto retry

