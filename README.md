# Mosquitto MQTT Broker - Windows Installer

Standalone Mosquitto MQTT Broker installer for Windows using Inno Setup.

## Features

- Installs Mosquitto MQTT Broker to `C:\Program Files\Mosquitto\`
- Configures as Windows Service (auto-start optional)
- Sets up Windows Firewall rules (port 1883)
- Pre-configured for local network use

## Prerequisites

### For Building

- **Windows** with [Inno Setup 6.x](https://jrsoftware.org/isinfo.php) installed
- **Mosquitto binaries** - Download from [mosquitto.org](https://mosquitto.org/download/)

### For Installation

- Windows 10/11 (64-bit)
- Administrator privileges

## Project Structure

```
mosquitto-installer/
├── assets/
│   └── circa-icon.ico       # Installer icon
├── config/
│   └── mosquitto.conf       # Default configuration
├── mosquitto/               # Mosquitto binaries (download separately)
│   ├── mosquitto.exe
│   ├── mosquitto_pub.exe
│   ├── mosquitto_sub.exe
│   └── *.dll
├── build.bat                # Build script (CMD)
├── build.ps1                # Build script (PowerShell)
└── mosquitto-setup.iss      # Inno Setup script
```

## Building the Installer

### 1. Download Mosquitto Binaries

Download the official Mosquitto Windows zip from [mosquitto.org/download](https://mosquitto.org/download/) and extract to `mosquitto-installer/mosquitto/`.

### 2. Build

**Using PowerShell:**
```powershell
cd mosquitto-installer
.\build.ps1
```

**Using CMD:**
```cmd
cd mosquitto-installer
build.bat
```

**Using Inno Setup directly:**
```cmd
iscc mosquitto-setup.iss
```

Output: `mosquitto-installer/output/Mosquitto-Setup-1.0.0.exe`

### 3. GitHub Actions (CI/CD)

Push a tag to trigger automatic build:
```bash
git tag mosquitto-v1.0.0
git push origin mosquitto-v1.0.0
```

Download the installer from [Actions](../../actions) → Select run → Artifacts.

## Installation

1. Run `Mosquitto-Setup-1.0.0.exe` as Administrator
2. Choose installation options:
   - ✅ Install as Windows Service
   - ⬜ Start service automatically on Windows startup
   - ✅ Configure Windows Firewall (allow port 1883)
3. Complete installation

## Testing After Installation

### Check Service Status
```powershell
Get-Service mosquitto
sc query mosquitto
```

### Start/Stop Service
```powershell
net start mosquitto
net stop mosquitto
```

### Check Port is Listening
```powershell
netstat -an | findstr 1883
```

### Test MQTT Communication

**Terminal 1 - Subscribe:**
```powershell
& "C:\Program Files\Mosquitto\bin\mosquitto_sub.exe" -h localhost -t test -v
```

**Terminal 2 - Publish:**
```powershell
& "C:\Program Files\Mosquitto\bin\mosquitto_pub.exe" -h localhost -t test -m "hello"
```

You should see `test hello` in Terminal 1.

### Run Manually (for debugging)
```powershell
& "C:\Program Files\Mosquitto\bin\mosquitto.exe" -c "C:\Program Files\Mosquitto\conf\mosquitto.conf" -v
```

## Configuration

Config file location: `C:\Program Files\Mosquitto\conf\mosquitto.conf`

Key settings:
| Setting | Value | Description |
|---------|-------|-------------|
| `listener` | `1883 0.0.0.0` | Listen on all interfaces, port 1883 |
| `allow_anonymous` | `true` | Allow connections without authentication |
| `persistence` | `true` | Enable message persistence |
| `log_dest` | `file ...` | Log to file |

## File Locations

| Type | Path |
|------|------|
| Binaries | `C:\Program Files\Mosquitto\bin\` |
| Config | `C:\Program Files\Mosquitto\conf\mosquitto.conf` |
| Logs | `C:\Program Files\Mosquitto\logs\mosquitto.log` |
| Data | `C:\Program Files\Mosquitto\data\` |

## Troubleshooting

### Service won't start
1. Check logs: `C:\Program Files\Mosquitto\logs\mosquitto.log`
2. Run manually with verbose: `mosquitto.exe -c mosquitto.conf -v`
3. Check if port 1883 is already in use: `netstat -an | findstr 1883`

### Permission denied
- Run PowerShell/CMD as Administrator

### Firewall blocking connections
- Check Windows Firewall rule "Mosquitto MQTT" exists
- Manually add: `netsh advfirewall firewall add rule name="Mosquitto MQTT" dir=in action=allow protocol=tcp localport=1883`

## Uninstall

Use Windows Settings → Apps → Mosquitto MQTT Broker → Uninstall

Or run the uninstaller from Start Menu.

## License

Mosquitto is licensed under EPL/EDL. See [mosquitto.org](https://mosquitto.org/) for details.

