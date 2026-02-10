#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_services() {
  local source_dir="$1"
  local target_dir="$2"
  local scope="$3" # "user" or "system"

  local ctl=(systemctl)
  [[ "$scope" == "user" ]] && ctl+=(--user) || ctl=(sudo systemctl)

  for service_file in "$source_dir"/*.service; do
    [[ -f "$service_file" ]] || return 0

    local filename servicename
    filename=$(basename "$service_file")
    servicename="${filename%.service}"

    echo "Installing $filename ($scope)..."

    if [[ -f "$target_dir/$filename" ]]; then
      local backup_name="${filename%.service}-$(date +%Y%m%d_%H%M%S).service.backup"
      [[ "$scope" == "system" ]] && sudo mv "$target_dir/$filename" "$target_dir/$backup_name" \
                                  || mv "$target_dir/$filename" "$target_dir/$backup_name"
      echo "  Backed up existing to $backup_name"
    fi

    [[ "$scope" == "system" ]] && sudo cp "$service_file" "$target_dir/" \
                                || cp "$service_file" "$target_dir/"

    "${ctl[@]}" daemon-reload
    echo "  Enabling $servicename..."
    "${ctl[@]}" enable "$servicename"
    echo "  Starting $servicename..."
    "${ctl[@]}" start "$servicename" || echo "  Warning: Failed to start $servicename"
  done
}

echo "Setting up systemd services..."

# User services
if ls "$SCRIPT_DIR/user/"*.service &>/dev/null; then
  mkdir -p "$HOME/.config/systemd/user"
  install_services "$SCRIPT_DIR/user" "$HOME/.config/systemd/user" "user"
fi

# System services
if ls "$SCRIPT_DIR/system/"*.service &>/dev/null; then
  install_services "$SCRIPT_DIR/system" "/etc/systemd/system" "system"
fi

echo ""
echo "Done!"
