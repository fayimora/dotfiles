#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_unit_files() {
  local source_dir="$1"
  local target_dir="$2"
  local scope="$3" # "user" or "system"
  local ext="$4"   # ".service" or ".timer"

  local ctl=(systemctl)
  [[ "$scope" == "user" ]] && ctl+=(--user) || ctl=(sudo systemctl)

  for unit_file in "$source_dir"/*"$ext"; do
    [[ -f "$unit_file" ]] || return 0

    local filename unitname
    filename=$(basename "$unit_file")
    unitname="${filename%$ext}"

    echo "Installing $filename ($scope)..."

    if [[ -f "$target_dir/$filename" ]]; then
      local backup_name="${unitname}-$(date +%Y%m%d_%H%M%S)${ext}.backup"
      [[ "$scope" == "system" ]] && sudo mv "$target_dir/$filename" "$target_dir/$backup_name" \
                                  || mv "$target_dir/$filename" "$target_dir/$backup_name"
      echo "  Backed up existing to $backup_name"
    fi

    [[ "$scope" == "system" ]] && sudo cp "$unit_file" "$target_dir/" \
                                || cp "$unit_file" "$target_dir/"

    "${ctl[@]}" daemon-reload
    echo "  Enabling $unitname..."
    "${ctl[@]}" enable "$unitname"
    echo "  Starting $unitname..."
    "${ctl[@]}" start "$unitname" || echo "  Warning: Failed to start $unitname"
  done
}

install_services() {
  install_unit_files "$1" "$2" "$3" ".service"
}

install_timers() {
  install_unit_files "$1" "$2" "$3" ".timer"
}

echo "Setting up systemd services..."

# User services
if ls "$SCRIPT_DIR/user/"*.service &>/dev/null; then
  mkdir -p "$HOME/.config/systemd/user"
  install_services "$SCRIPT_DIR/user" "$HOME/.config/systemd/user" "user"
fi

# User timers
if ls "$SCRIPT_DIR/user/"*.timer &>/dev/null; then
  mkdir -p "$HOME/.config/systemd/user"
  install_timers "$SCRIPT_DIR/user" "$HOME/.config/systemd/user" "user"
fi

# System services
if ls "$SCRIPT_DIR/system/"*.service &>/dev/null; then
  install_services "$SCRIPT_DIR/system" "/etc/systemd/system" "system"
fi

# System timers
if ls "$SCRIPT_DIR/system/"*.timer &>/dev/null; then
  install_timers "$SCRIPT_DIR/system" "/etc/systemd/system" "system"
fi

echo ""
echo "Done!"
