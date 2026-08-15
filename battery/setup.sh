#!/usr/bin/env bash

set -euo pipefail

battery_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
config_dir=${XDG_CONFIG_HOME:-"$HOME/.config"}
plugin_dir="$config_dir/omarchy/plugins/fayi.battery"
plugin_source="$battery_dir/omarchy/fayi.battery"
upower_source="$battery_dir/upower/90-critical-battery.conf"
upower_target=/etc/UPower/UPower.conf.d/90-critical-battery.conf

if ! command -v omarchy >/dev/null 2>&1; then
  printf 'Omarchy is required for this battery setup.\n' >&2
  exit 1
fi

if ! omarchy hibernation available; then
  printf 'Hibernation is not configured. Run `omarchy hibernation setup` first.\n' >&2
  exit 1
fi

sudo install -o root -g root -m 0644 -D "$upower_source" "$upower_target"

mkdir -p "$(dirname -- "$plugin_dir")"
if [[ -e $plugin_dir || -L $plugin_dir ]]; then
  if [[ -L $plugin_dir && $(readlink -f -- "$plugin_dir") == $(readlink -f -- "$plugin_source") ]]; then
    :
  else
    backup="$plugin_dir.bak.$(date +%s)"
    mv -- "$plugin_dir" "$backup"
    printf 'Backed up existing battery plugin to %s\n' "$backup"
    ln -s -- "$plugin_source" "$plugin_dir"
  fi
else
  ln -s -- "$plugin_source" "$plugin_dir"
fi

sudo systemctl restart upower.service

if omarchy-shell shell rescanPlugins >/dev/null 2>&1; then
  omarchy plugin enable fayi.battery >/dev/null
else
  printf 'Omarchy shell is not running; enable fayi.battery after login.\n'
fi

printf 'Battery warning: 15%%; hibernation action: 7%%.\n'
