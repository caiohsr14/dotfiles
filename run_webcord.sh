#!/bin/bash

# Function to check if Waybar is running
is_waybar_running() {
    pgrep waybar > /dev/null 2>&1
}

# Log file
LOG_FILE="/tmp/start_apps.log"
echo "Starting script at $(date)" > $LOG_FILE

# Timeout in seconds
TIMEOUT=30
elapsed=0

# Wait until Waybar is running or timeout
while ! is_waybar_running; do
    sleep 1
    elapsed=$((elapsed + 1))
    if [ $elapsed -ge $TIMEOUT ]; then
        echo "Timeout reached. Waybar did not start within $TIMEOUT seconds." >> $LOG_FILE
        exit 1
    fi
done

echo "Waybar is running. Starting other application." >> $LOG_FILE
sleep 1

# Start the other application on a specific workspace
hyprctl dispatch exec \[workspace 2\] bash -c "webcord --ozone-platform=wayland --ozone-platform-hint=auto --enable-features=UseOzonePlatform,WaylandWindowDecorations" >> $LOG_FILE 2>&1
