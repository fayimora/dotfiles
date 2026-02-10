# Path to your dotfiles.
export DOTFILES="$HOME/Code/dotfiles"
export CONFIG_DIR="$XDG_CONFIG_HOME"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="robbyrussell"
# ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="dd/mm/yyyy"
ZSH_CUSTOM=$DOTFILES/zsh/custom/

plugins=(1password direnv docker-compose docker dotenv git git-extras vi-mode zoxide starship)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LC_ALL=en_US.UTF-8
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

source $DOTFILES/zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $DOTFILES/zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $DOTFILES/zsh/custom/plugins/zsh-completions/zsh-completions.plugin.zsh
source $DOTFILES/zsh/custom/plugins/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh

source <(fzf --zsh)

# alias cd to zoxide
eval "$(zoxide init --cmd cd zsh)"

# eval "$(starship init zsh)"
# Check that the function `starship_zle-keymap-select()` is defined.
# xref: https://github.com/starship/starship/issues/3418
# xref: https://github.com/starship/starship/issues/3418#issuecomment-1711630970
type starship_zle-keymap-select >/dev/null || \
  {
    echo "Load starship"
    eval "$(/usr/local/bin/starship init zsh)"
  }

export PATH="$PATH:/home/fayi/.local/share/coursier/bin"
. "$HOME/.cargo/env"

[[ -n $TMUX ]] && export TERM="xterm-256color"

eval "$(mise activate zsh)"

# pnpm
export PNPM_HOME="/home/fayi/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

eval "$(direnv hook zsh)"

eval "$(mise activate zsh)"

eval "$(/usr/bin/try init ~/Code/tries)"

if [ -e /home/fayi/.nix-profile/etc/profile.d/nix.sh ]; then . /home/fayi/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
