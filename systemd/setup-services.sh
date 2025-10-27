#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_DIR="$HOME/.config/systemd/user"

echo "Setting up systemd user services..."

mkdir -p "$SERVICE_DIR"

# Copy all .service files to user systemd directory
for service_file in "$SCRIPT_DIR"/*.service; do
  if [[ -f "$service_file" ]]; then
    filename=$(basename "$service_file")
    echo "Installing $filename..."
    # TODO: Check if file already exists and backup(append timestamp) before copying
    if [[ -f "$SERVICE_DIR/$filename" ]]; then
      backup_name="${filename%.service}-$(date +%Y%m%d_%H%M%S).service.backup"
      mv "$SERVICE_DIR/$filename" "$SERVICE_DIR/$backup_name"
      echo "Backed up existing $filename to $backup_name"
    fi
    cp "$service_file" "$SERVICE_DIR/"
  fi
done

echo "Reloading systemd daemon..."
systemctl --user daemon-reload

# Enable and start all services
for service_file in "$SCRIPT_DIR"/*.service; do
  if [[ -f "$service_file" ]]; then
    filename=$(basename "$service_file")
    servicename="${filename%.service}"

    echo "Enabling $servicename..."
    systemctl --user enable "$servicename"

    echo "Starting $servicename..."
    systemctl --user start "$servicename" || echo "Warning: Failed to start $servicename"
  fi
done

echo "Done! Check status with: systemctl --user status [service-name]"
echo "List all user services: systemctl --user list-units --type=service"
