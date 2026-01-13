# Circa Mosquitto MQTT Broker - Build Script (PowerShell)
#
# This script builds the Mosquitto installer:
# 1. Downloads Mosquitto binaries (if not present)
# 2. Creates the Inno Setup installer
#
# Prerequisites:
# - Inno Setup 6.x (ISCC.exe in PATH or at default location)
#
# Usage:
#   .\build.ps1                 # Full build
#   .\build.ps1 -SkipDownload   # Skip download (use existing files)
#   .\build.ps1 -SkipInstaller  # Skip installer creation
#   .\build.ps1 -Clean          # Clean and rebuild

param(
    [switch]$SkipDownload,
    [switch]$SkipInstaller,
    [switch]$Clean
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Version configuration
$mosquittoVersion = "2.0.20"
$installerVersion = "1.0.0"

# Clean if requested
if ($Clean) {
    Write-Host "Cleaning build artifacts..." -ForegroundColor Yellow
    Remove-Item -Path "$scriptDir\mosquitto" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$scriptDir\output" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Clean complete!" -ForegroundColor Green
}

# ============================================
# Step 1: Download Mosquitto
# ============================================
if (-not $SkipDownload) {
    Write-Host ""
    Write-Host "[1/2] Downloading Mosquitto $mosquittoVersion..." -ForegroundColor Cyan
    
    $mosquittoDir = "$scriptDir\mosquitto"
    $mosquittoZip = "$scriptDir\mosquitto-$mosquittoVersion.zip"
    $downloadUrl = "https://mosquitto.org/files/binary/win64/mosquitto-$mosquittoVersion-install-windows-x64.zip"
    
    # Create directory
    New-Item -ItemType Directory -Force -Path $mosquittoDir | Out-Null
    
    # Download if zip doesn't exist
    if (-not (Test-Path $mosquittoZip)) {
        Write-Host "  Downloading from $downloadUrl..." -ForegroundColor Gray
        try {
            Invoke-WebRequest -Uri $downloadUrl -OutFile $mosquittoZip -UseBasicParsing
        } catch {
            Write-Host "  Failed to download. Trying alternative URL..." -ForegroundColor Yellow
            $altUrl = "https://mosquitto.org/files/binary/win64/mosquitto-$mosquittoVersion.zip"
            Invoke-WebRequest -Uri $altUrl -OutFile $mosquittoZip -UseBasicParsing
        }
    } else {
        Write-Host "  Using cached download: $mosquittoZip" -ForegroundColor Gray
    }
    
    # Extract
    Write-Host "  Extracting..." -ForegroundColor Gray
    Expand-Archive -Path $mosquittoZip -DestinationPath $mosquittoDir -Force
    
    # Move files from subdirectory if needed
    $subdir = Get-ChildItem -Path $mosquittoDir -Directory | Select-Object -First 1
    if ($subdir) {
        Get-ChildItem -Path $subdir.FullName | Move-Item -Destination $mosquittoDir -Force
        Remove-Item -Path $subdir.FullName -Force -Recurse
    }
    
    # Verify required files
    $requiredFiles = @("mosquitto.exe", "mosquitto.dll")
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path "$mosquittoDir\$file")) {
            throw "Missing required file: $file"
        }
    }
    
    Write-Host "  Download complete!" -ForegroundColor Green
} else {
    Write-Host "[1/2] Skipping Mosquitto download" -ForegroundColor Gray
}

# ============================================
# Step 2: Build Installer
# ============================================
if (-not $SkipInstaller) {
    Write-Host ""
    Write-Host "[2/2] Building Installer..." -ForegroundColor Cyan
    
    # Find Inno Setup compiler
    $isccPaths = @(
        "iscc",
        "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
        "C:\Program Files\Inno Setup 6\ISCC.exe"
    )
    
    $iscc = $null
    foreach ($path in $isccPaths) {
        if (Get-Command $path -ErrorAction SilentlyContinue) {
            $iscc = $path
            break
        }
        if (Test-Path $path) {
            $iscc = $path
            break
        }
    }
    
    if (-not $iscc) {
        throw "Inno Setup not found! Please install from https://jrsoftware.org/isinfo.php"
    }
    
    Write-Host "  Using Inno Setup: $iscc" -ForegroundColor Gray
    
    # Verify required files exist
    $requiredPaths = @(
        "$scriptDir\mosquitto\mosquitto.exe",
        "$scriptDir\config\mosquitto.conf",
        "$scriptDir\mosquitto-setup.iss"
    )
    
    foreach ($path in $requiredPaths) {
        if (-not (Test-Path $path)) {
            throw "Missing required file: $path"
        }
    }
    
    # Create output directory
    New-Item -ItemType Directory -Force -Path "$scriptDir\output" | Out-Null
    
    # Run Inno Setup compiler
    Push-Location $scriptDir
    try {
        & $iscc "mosquitto-setup.iss"
        if ($LASTEXITCODE -ne 0) {
            throw "Inno Setup compilation failed!"
        }
        Write-Host "  Installer build complete!" -ForegroundColor Green
    } finally {
        Pop-Location
    }
} else {
    Write-Host "[2/2] Skipping Installer build" -ForegroundColor Gray
}

# ============================================
# Summary
# ============================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Build Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Output: $scriptDir\output\Circa-Mosquitto-Setup-$installerVersion.exe"
Write-Host ""

