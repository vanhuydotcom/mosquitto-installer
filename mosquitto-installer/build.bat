@echo off
REM Circa Mosquitto MQTT Broker - Build Script Wrapper
REM
REM Usage:
REM   build.bat              - Full build (download + installer)
REM   build.bat download     - Download Mosquitto only
REM   build.bat installer    - Build installer only (requires download first)
REM   build.bat clean        - Clean and rebuild

cd /d "%~dp0"

echo.
echo ============================================
echo   Circa Mosquitto Installer - Build
echo ============================================
echo.

if "%1"=="" goto :full
if "%1"=="download" goto :download
if "%1"=="installer" goto :installer
if "%1"=="clean" goto :clean
if "%1"=="help" goto :help
goto :full

:download
echo Downloading Mosquitto...
powershell -ExecutionPolicy Bypass -File "build.ps1" -SkipInstaller
goto :done

:installer
echo Building installer only...
powershell -ExecutionPolicy Bypass -File "build.ps1" -SkipDownload
goto :done

:clean
echo Running clean build...
powershell -ExecutionPolicy Bypass -File "build.ps1" -Clean
goto :done

:help
echo Usage: build.bat [option]
echo.
echo Options:
echo   (none)     Full build - download Mosquitto + create installer
echo   download   Download Mosquitto binaries only
echo   installer  Build installer only (requires previous download)
echo   clean      Clean all artifacts and rebuild
echo   help       Show this help message
echo.
goto :eof

:full
echo Running full build...
powershell -ExecutionPolicy Bypass -File "build.ps1"
goto :done

:done
if %errorlevel% neq 0 (
    echo.
    echo Build failed with error code: %errorlevel%
    exit /b %errorlevel%
)

echo.
echo Build completed successfully!
echo Output: output\Circa-Mosquitto-Setup-*.exe
exit /b 0

