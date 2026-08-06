if [[ -x "$HOME/.local/bin/mise" ]]; then
  eval "$("$HOME/.local/bin/mise" activate zsh)"
elif (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi
