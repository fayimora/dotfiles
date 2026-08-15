#!/usr/bin/env bash

set -euo pipefail

dotfiles_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

printf 'Configuring laptop battery warning and hibernation policy...\n'
"$dotfiles_dir/battery/setup.sh"
