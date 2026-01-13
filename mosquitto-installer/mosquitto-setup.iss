; Circa Mosquitto MQTT Broker - Inno Setup Installer Script
;
; Standalone Mosquitto MQTT Broker installer
; - Installs Mosquitto binaries
; - Configures as Windows Service (auto-start)
; - Sets up firewall rules
;
; Build: iscc mosquitto-setup.iss

#define MyAppName "Circa Mosquitto MQTT Broker"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Circa"
#define MyAppURL "https://circa.vn"

[Setup]
AppId={{B8F9E0D3-4C5D-6F7A-8B9C-0D1E2F3A4B5C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}

DefaultDirName={autopf}\Circa\Mosquitto
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes

OutputDir=output
OutputBaseFilename=Circa-Mosquitto-Setup-{#MyAppVersion}
SetupIconFile=assets\circa-icon.ico

Compression=lzma2/ultra64
SolidCompression=yes

PrivilegesRequired=admin
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

UninstallDisplayName={#MyAppName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "installservice"; Description: "Install as Windows Service"; Flags: checkedonce
Name: "autostart"; Description: "Start service automatically on Windows startup"; Flags: unchecked
Name: "firewall"; Description: "Configure Windows Firewall (allow port 1883)"; Flags: checkedonce

[Dirs]
Name: "{app}\bin"; Permissions: admins-full
Name: "{app}\conf"; Permissions: admins-full users-modify
Name: "{app}\data"; Permissions: admins-full users-modify
Name: "{app}\logs"; Permissions: admins-full users-modify

[Files]
; Mosquitto binaries
Source: "mosquitto\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs

; Configuration file
Source: "config\mosquitto.conf"; DestDir: "{app}\conf"; Flags: ignoreversion onlyifdoesntexist

[Icons]
Name: "{group}\Start Mosquitto"; Filename: "net"; Parameters: "start mosquitto"; IconFilename: "{app}\bin\mosquitto.ico"
Name: "{group}\Stop Mosquitto"; Filename: "net"; Parameters: "stop mosquitto"; IconFilename: "{app}\bin\mosquitto.ico"
Name: "{group}\Mosquitto Logs"; Filename: "{app}\logs"
Name: "{group}\Mosquitto Configuration"; Filename: "{app}\conf\mosquitto.conf"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"

[Run]
; Stop existing service if running
Filename: "net"; Parameters: "stop mosquitto"; Flags: runhidden waituntilterminated; Check: ServiceExists('mosquitto')

; Install as Windows Service
Filename: "{app}\bin\mosquitto.exe"; Parameters: "install"; StatusMsg: "Installing Mosquitto service..."; Flags: runhidden waituntilterminated; Tasks: installservice

; Configure service binary path with config file (use sc.exe to avoid PowerShell alias)
Filename: "{sys}\sc.exe"; Parameters: "config mosquitto binPath= ""\""""{app}\bin\mosquitto.exe\"""" -c \""""{app}\conf\mosquitto.conf\"""""; StatusMsg: "Configuring service path..."; Flags: runhidden waituntilterminated; Tasks: installservice

; Configure service to auto-start (only if autostart task selected)
Filename: "{sys}\sc.exe"; Parameters: "config mosquitto start= auto"; StatusMsg: "Configuring auto-start..."; Flags: runhidden waituntilterminated; Tasks: autostart

; Configure service to manual start (if autostart not selected)
Filename: "{sys}\sc.exe"; Parameters: "config mosquitto start= demand"; StatusMsg: "Configuring manual start..."; Flags: runhidden waituntilterminated; Tasks: installservice and not autostart

; Configure Windows Firewall
Filename: "netsh"; Parameters: "advfirewall firewall add rule name=""Circa Mosquitto MQTT"" dir=in action=allow protocol=tcp localport=1883 profile=private,domain"; StatusMsg: "Configuring firewall..."; Flags: runhidden waituntilterminated; Tasks: firewall

; Start service now (optional - ask user)
Filename: "net"; Parameters: "start mosquitto"; Description: "Start Mosquitto service now"; StatusMsg: "Starting Mosquitto service..."; Flags: runhidden waituntilterminated postinstall skipifsilent; Tasks: installservice

[UninstallRun]
; Stop and remove service
Filename: "net"; Parameters: "stop mosquitto"; RunOnceId: "StopMosquitto"; Flags: runhidden waituntilterminated
Filename: "{app}\bin\mosquitto.exe"; Parameters: "uninstall"; RunOnceId: "UninstallMosquitto"; Flags: runhidden waituntilterminated

; Remove firewall rule
Filename: "netsh"; Parameters: "advfirewall firewall delete rule name=""Circa Mosquitto MQTT"""; RunOnceId: "RemoveFirewall"; Flags: runhidden waituntilterminated

[UninstallDelete]
Type: files; Name: "{app}\logs\*.log"
Type: files; Name: "{app}\data\*"
Type: dirifempty; Name: "{app}\logs"
Type: dirifempty; Name: "{app}\data"

[Code]
function ServiceExists(ServiceName: String): Boolean;
var
  ResultCode: Integer;
begin
  Result := Exec('sc.exe', 'query "' + ServiceName + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
end;

