#!/bin/bash

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Set path to ADB
ADB=~/Library/Android/sdk/platform-tools/adb
APK_PATH="./Space Shooter.apk"
PACKAGE_NAME="com.nqmgaming.spaceshooter"

# Function to print messages with color
print_message() {
  echo -e "${2}$1${NC}"
}

# Function to check if ADB is working and device connected
check_adb_connection() {
  # Check if ADB exists
  if [ ! -f "$ADB" ]; then
    print_message "Error: ADB not found at $ADB" "$RED"
    print_message "Please install Android SDK or update ADB path in the script." "$YELLOW"
    exit 1
  fi
  
  # Check if any device is connected
  if [ -z "$($ADB devices | grep -v "List" | grep "device")" ]; then
    print_message "Error: No Android device connected!" "$RED"
    print_message "Please connect a device and ensure USB debugging is enabled." "$YELLOW"
    exit 1
  fi
  
  print_message "✓ Device connected" "$GREEN"
}

# Function to check if the APK exists
check_apk() {
  if [ ! -f "$APK_PATH" ]; then
    print_message "Error: APK not found at $APK_PATH" "$RED"
    print_message "Please export your project first." "$YELLOW"
    exit 1
  fi
  
  APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
  print_message "✓ Found APK (Size: $APK_SIZE)" "$GREEN"
}

# Function to stop the app if it's running
stop_app() {
  print_message "Stopping app if running..." "$BLUE"
  $ADB shell am force-stop $PACKAGE_NAME
}

# Function to uninstall the app
uninstall_app() {
  print_message "Uninstalling previous version..." "$BLUE"
  UNINSTALL_RESULT=$($ADB uninstall $PACKAGE_NAME 2>&1)
  
  if [[ $UNINSTALL_RESULT == *"Success"* ]]; then
    print_message "✓ Uninstallation successful" "$GREEN"
    return 0
  else
    # If the app wasn't installed, that's okay too
    if [[ $UNINSTALL_RESULT == *"not installed"* ]]; then
      print_message "App was not previously installed" "$YELLOW"
      return 0
    else
      print_message "⚠ Uninstallation warning: $UNINSTALL_RESULT" "$YELLOW"
      return 1
    fi
  fi
}

# Function to install the APK
install_apk() {
  print_message "Installing APK..." "$BLUE"
  INSTALL_RESULT=$($ADB install -r "$APK_PATH" 2>&1)
  
  if [[ $INSTALL_RESULT == *"Success"* ]]; then
    print_message "✓ Installation successful" "$GREEN"
    return 0
  else
    # Handle signature mismatch by uninstalling and reinstalling
    if [[ $INSTALL_RESULT == *"INSTALL_FAILED_UPDATE_INCOMPATIBLE"* ]] || 
       [[ $INSTALL_RESULT == *"signatures do not match"* ]]; then
      print_message "⚠ Signature mismatch detected" "$YELLOW"
      print_message "Attempting to uninstall and reinstall..." "$BLUE"
      
      if uninstall_app; then
        # Try to install again after uninstalling
        INSTALL_RESULT=$($ADB install "$APK_PATH" 2>&1)
        
        if [[ $INSTALL_RESULT == *"Success"* ]]; then
          print_message "✓ Fresh installation successful" "$GREEN"
          return 0
        fi
      fi
    fi
    
    # If we reached here, installation failed
    print_message "⨯ Installation failed" "$RED"
    print_message "$INSTALL_RESULT" "$YELLOW"
    exit 1
  fi
}

# Function to start the app
start_app() {
  print_message "Starting app..." "$BLUE"
  START_RESULT=$($ADB shell am start -n $PACKAGE_NAME/com.godot.game.GodotApp 2>&1)
  
  if [[ $START_RESULT == *"Error"* ]]; then
    print_message "⨯ Failed to start app" "$RED"
    print_message "$START_RESULT" "$YELLOW"
    exit 1
  else
    print_message "✓ App started successfully" "$GREEN"
  fi
}

# Function to show app logs
show_logs() {
  if [ "$1" == "--logs" ]; then
    print_message "Showing logs (press Ctrl+C to stop):" "$BLUE"
    $ADB logcat -s "GodotApp" "godot" "Unity" "AndroidRuntime" "DEBUG"
  fi
}

# Function to display script usage
show_help() {
  print_message "Usage: $0 [OPTIONS]" "$BLUE"
  print_message "Options:" "$BLUE"
  print_message "  --help      Display this help message" "$NC"
  print_message "  --logs      Show application logs after launch" "$NC"
  print_message "  --clean     Force uninstall before installation" "$NC"
  exit 0
}

# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --help)
      show_help
      ;;
    --clean)
      FORCE_CLEAN=true
      ;;
  esac
done

# Main execution
print_message "===== Godot Android Deployment Tool =====" "$BLUE"

check_adb_connection
check_apk
stop_app

# If force clean is enabled, uninstall first
if [ "$FORCE_CLEAN" = true ]; then
  uninstall_app
fi

install_apk
start_app
show_logs $1

print_message "===== Deployment Complete =====" "$GREEN"
