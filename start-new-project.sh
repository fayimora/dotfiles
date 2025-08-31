#!/usr/bin/env sh

if [ -n "$1" ]; then
  session_name="$1"
else
  session_name=$(basename "$(pwd)")
fi

echo "Creating new project: $session_name"

if tmux has-session -t "$session_name" 2>/dev/null; then
  echo "Session '$session_name' already exists. Attaching..."
  tmux attach-session -t "$session_name"
  exit 0
fi

# Get the base index from tmux configuration
base_index=$(tmux show-options -g base-index 2>/dev/null | cut -d' ' -f2)
# Default to 0 if not set
base_index=${base_index:-0}

# Create new tmux session with vim in first window
# tmux new-session -d -s "$session_name" -c "$(pwd)" -n "neovim" 'nvim .'

# Create new tmux session with neovim in first window
tmux new-session -d -s "$session_name" -c "$(pwd)" -n "neovim"
tmux send-keys -t "$session_name:neovim" 'nvim .' Enter

tmux new-window -t "$session_name" -c "$(pwd)"
# tmux new-window -t "$session_name" -c "$(pwd)" -n "lr-tasks"

# Focus back on the first window (vim) using the base index
# tmux select-window -t "$session_name:$base_index"
tmux select-window -t "$session_name:{start}"

# Attach to the session
tmux attach-session -t "$session_name"
