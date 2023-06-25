#!/bin/sh

info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

info "Setting up your Mac..."

$DOTFILES=$HOME/.dotfiles

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  info "Installing Oh My Zsh..."
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
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

# Setup neovim
info "Setting up neovim..."
rm -rf $HOME/.config/nvim
rm -rf $HOME/.local/share/nvim
git clone https://github.com/NvChad/NvChad $HOME/.config/nvim --depth 1
ln -s $DOTFILES/nvchad/custom ~/.config/nvim/lua/custom

# Link tmux config
info "Setting up tmux..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -s $DOTFILES/.tmux.conf $HOME/.tmux.conf

# Symlink the Mackup config file to the home directory
# ln -s $DOTFILES/.mackup.cfg $HOME/.mackup.cfg

# Set macOS preferences - we will run this last because this will reload the shell
# source $DOTFILES/.macos
