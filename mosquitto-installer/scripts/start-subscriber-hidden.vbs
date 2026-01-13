' Start MQTT Subscriber in background (hidden window)
' Usage: wscript start-subscriber-hidden.vbs "C:\Program Files\Mosquitto"

Set WshShell = CreateObject("WScript.Shell")
InstallDir = WScript.Arguments(0)
If InstallDir = "" Then InstallDir = "C:\Program Files\Mosquitto"

WshShell.Run Chr(34) & InstallDir & "\scripts\mqtt-subscriber.bat" & Chr(34) & " " & Chr(34) & InstallDir & Chr(34), 0, False

