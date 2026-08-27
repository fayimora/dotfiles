# Rsync-on-change watchers: rsw starts one in the background, lsw lists, dsw stops
rsw() {
  if (( $# != 2 )); then
    echo "Usage: rsw <source> <destination>"
    return 1
  fi

  local src="${1%/}"
  local dest="$2"
  local sockets="${XDG_RUNTIME_DIR:-$HOME/.ssh/sockets}"
  local rsh="ssh -o ControlMaster=auto -o ControlPath=$sockets/rsw-%r@%h:%p -o ControlPersist=yes"

  mkdir -p "$sockets"
  setsid --fork env RSYNC_RSH="$rsh" zsh -c '
    rsync -a "$1/" "$2"
    while inotifywait -r -q -e modify,create,delete,move "$1"; do
      rsync -a "$1/" "$2"
    done
  ' rsw-watch "$src" "$dest" >/dev/null 2>&1

  echo "Watching $src -> $dest"
}

lsw() {
  local pid cmd rest
  local found=0

  while read -r pid cmd; do
    rest="${cmd##*rsw-watch }"
    echo "$pid: ${rest% *} -> ${rest##* }"
    found=1
  done < <(pgrep -af 'rsw-watch ')

  (( found )) || echo "No active watches"
}

dsw() {
  local pid
  local found=0

  for pid in $(pgrep -f 'rsw-watch '); do
    if kill -- -"$pid" 2>/dev/null; then
      echo "Stopped watch (pid $pid)"
      found=1
    fi
  done

  (( found )) || echo "No active watches"
}
