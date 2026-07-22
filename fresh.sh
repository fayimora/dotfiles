#!/bin/sh

info() {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

info "Setting up your Mac..."

DOTFILES="$HOME/.dotfiles"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$CONFIG_DIR"
info "Dotfiles path: $DOTFILES"

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  info "Installing Oh My Zsh..."
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>$HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
info "Cleaning up zsh..."
rm -rf $HOME/.zshrc
ln -s $DOTFILES/zsh/.zshrc $HOME/.zshrc

# Update Homebrew recipes
info "Updating Homebrew..."
brew update

# Install all our dependencies with bundle (See Brewfile)
info "Installing dependencies fron bundle..."
brew tap homebrew/bundle
# ln -s $DOTFILES/Brewfile $HOME/.Brewfile
HOMEBREW_BUNDLE_FILE=$DOTFILES/Brewfile brew bundle install

# Install sdkman
curl -s "https://get.sdkman.io" | bash

# Setup neovim
info "Setting up neovim..."
rm -rf $CONFIG_DIR/nvim
rm -rf $HOME/.local/share/nvim
ln -s $DOTFILES/nvim $CONFIG_DIR/nvim

# Setup git
info "Setting up git..."
ln -fs $DOTFILES/gitconfig $HOME/.gitconfig
mkdir -p $HOME/.config/lazygit
ln -fs $DOTFILES/lazygit/config.yml $HOME/.config/lazygit/config.yml

# Link tmux config
info "Setting up tmux..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -fs $DOTFILES/.tmux.conf $HOME/.tmux.conf

# Symlink the Mackup config file to the home directory
# ln -s $DOTFILES/.mackup.cfg $HOME/.mackup.cfg

# Setup aerospace, sketchybar and jankyborders
mkdir -p $CONFIG_DIR/{aerospace,sketchybar/plugins,borders}
ln -s $DOTFILES/aerospace/aerospace.toml $CONFIG_DIR/aerospace.toml

ln -sf $DOTFILES/sketchybar/sketchybarrc $CONFIG_DIR/sketchybar/sketchybarrc
ln -sf $DOTFILES/sketchybar/plugins $CONFIG_DIR/sketchybar/plugins
# chmod +x $DOTFILES/sketchybar/plugins/*

ln -sf $DOTFILES/jankyborders/bordersrc $CONFIG_DIR/borders/bordersrc

# link Kitty and Ghostty configs
mkdir -p $CONFIG_DIR/kitty
mkdir -p $CONFIG_DIR/ghostty

ln -sf $DOTFILES/kitty.conf $CONFIG_DIR/kitty/kitty.conf
ln -sf $DOTFILES/ghostty $CONFIG_DIR/ghostty

# Setup Yazi
info "Setting up Yazi..."
rm -rf $CONFIG_DIR/yazi
ln -s $DOTFILES/yazi $CONFIG_DIR/yazi

if command -v ya >/dev/null 2>&1; then
  info "Installing Yazi packages..."
  ya pkg install || info "Failed to install Yazi packages"
else
  info "Yazi package manager 'ya' was not found; skipping Yazi package install"
fi

# Setup Herdr
info "Setting up Herdr..."
mkdir -p "$CONFIG_DIR/herdr"
ln -sfn "$DOTFILES/herdr/config.toml" "$CONFIG_DIR/herdr/config.toml"

if command -v herdr >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
  "$DOTFILES/bin/sync-herdr-config" --config "$CONFIG_DIR/herdr/config.toml" --no-reload || \
    info "Failed to synchronize Herdr config"
else
  info "Herdr or Python 3 was not found; skipping Herdr config synchronization"
fi

# Symlink pi coding agent resources
mkdir -p "$HOME/.pi/agent/extensions"
ln -sfn "$DOTFILES/pi/agent/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"
ln -sfn "$DOTFILES/pi/agent/APPEND_SYSTEM.md" "$HOME/.pi/agent/APPEND_SYSTEM.md"
for f in "$DOTFILES"/pi/agent/extensions/*; do
  ln -sf "$f" "$HOME/.pi/agent/extensions/"
done

# Set macOS preferences - we will run this last because this will reload the shell
info "Setting up macOS..."
# source $DOTFILES/.macos

info "All done!"
