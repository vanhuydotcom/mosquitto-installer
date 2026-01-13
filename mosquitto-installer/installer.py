import os
import sys
import subprocess
import urllib.request
import time
import ctypes

# Configuration
MOSQUITTO_URL = "https://mosquitto.org/files/binary/win64/mosquitto-2.0.22-install-windows-x64.exe"
MOSQUITTO_PATH = r"C:\Program Files\mosquitto"
MQTT_HOST = "localhost"
MQTT_PORT = "1883"
MQTT_TOPIC = "reader/#"


def is_admin():
    """Check if running as administrator"""
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False


def run_as_admin():
    """Re-run the script as administrator"""
    ctypes.windll.shell32.ShellExecuteW(
        None, "runas", sys.executable, " ".join(sys.argv), None, 1
    )
    sys.exit(0)


def download_file(url, dest):
    """Download file with progress"""
    print(f"Downloading from {url}...")
    try:
        urllib.request.urlretrieve(url, dest)
        print("Download complete!")
        return True
    except Exception as e:
        print(f"Download failed: {e}")
        return False


def install_mosquitto():
    """Download and install Mosquitto"""
    print("\n" + "=" * 50)
    print("  Mosquitto MQTT Broker Installer")
    print("=" * 50 + "\n")

    # Check if already installed
    mosquitto_exe = os.path.join(MOSQUITTO_PATH, "mosquitto.exe")
    if os.path.exists(mosquitto_exe):
        print("Mosquitto is already installed!")
        response = input("Do you want to reinstall? (y/n): ").strip().lower()
        if response != 'y':
            return True

    # Download installer
    temp_installer = os.path.join(os.environ.get('TEMP', '.'), "mosquitto-setup.exe")
    if not download_file(MOSQUITTO_URL, temp_installer):
        return False

    # Run installer silently
    print("\nInstalling Mosquitto...")
    try:
        subprocess.run([temp_installer, "/S"], check=True)
        time.sleep(5)  # Wait for installation
        print("Mosquitto installed successfully!")
    except Exception as e:
        print(f"Installation failed: {e}")
        return False
    finally:
        # Cleanup
        if os.path.exists(temp_installer):
            os.remove(temp_installer)

    # Start Mosquitto service
    print("\nStarting Mosquitto service...")
    try:
        subprocess.run(["net", "stop", "mosquitto"], capture_output=True)
        subprocess.run([os.path.join(MOSQUITTO_PATH, "mosquitto.exe"), "install"], capture_output=True)
        subprocess.run(["net", "start", "mosquitto"], check=True)
        print("Mosquitto service started!")
    except Exception as e:
        print(f"Service start warning: {e}")

    return True


def run_subscriber():
    """Run MQTT subscriber for reader/# topic"""
    print("\n" + "=" * 50)
    print("  MQTT Subscriber - reader/# topic")
    print("=" * 50)
    print(f"\nHost: {MQTT_HOST}")
    print(f"Port: {MQTT_PORT}")
    print(f"Topic: {MQTT_TOPIC}")
    print("\nListening for messages... (Press Ctrl+C to stop)\n")
    print("=" * 50 + "\n")

    mosquitto_sub = os.path.join(MOSQUITTO_PATH, "mosquitto_sub.exe")
    
    if not os.path.exists(mosquitto_sub):
        print("ERROR: mosquitto_sub.exe not found!")
        return

    try:
        subprocess.run([
            mosquitto_sub,
            "-h", MQTT_HOST,
            "-p", MQTT_PORT,
            "-t", MQTT_TOPIC,
            "-v"
        ])
    except KeyboardInterrupt:
        print("\nSubscriber stopped.")
    except Exception as e:
        print(f"Error: {e}")


def main():
    # Check for admin rights
    if not is_admin():
        print("Requesting administrator privileges...")
        run_as_admin()
        return

    # Install Mosquitto
    if install_mosquitto():
        print("\n" + "=" * 50)
        print("  Installation Complete!")
        print("=" * 50)
        
        # Ask to run subscriber
        response = input("\nDo you want to start the subscriber now? (y/n): ").strip().lower()
        if response == 'y':
            run_subscriber()
        else:
            print("\nTo run subscriber later, run this program again.")
            input("\nPress Enter to exit...")
    else:
        print("\nInstallation failed!")
        input("\nPress Enter to exit...")


if __name__ == "__main__":
    main()

