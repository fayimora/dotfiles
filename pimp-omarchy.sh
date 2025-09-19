#!/usr/bin/ssh

info() {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

export DOTFILES="$HOME/Code/dotfiles/"
export CONFIG_DIR="$XDG_CONFIG_HOME"

info "Dotfiles path: $DOTFILES"
info "Config path: $CONFIG_DIR"

info "\nPimping up your Omarchy..."

info "Installing required packages..."
yay -S --noconfirm --needed zsh tmux tmux-plugin-manager opencode-bin lnav httpie github-cli nfs-utils \
  zen-browser discord nordvpn-bin telegram-desktop-bin visual-studio-code-bin ghostty-git ttf-jetbrains-mono-nerd \
  slack-desktop discord go-task brave-bin

info "Installing dev environments..."
mise use --global coursier java direnv node bun deno go python rust
cs setup # setup scala environment

info "Setup nordvpn"
sudo groupadd nordvpn
sudo usermod -aG nordvpn $USER
systemctl enable --now nordvpnd

# Install starship
info "Installing starship"
sudo pacman -Sy --noconfirm --needed starship

info "Setting up zsh..."
if ! command -v omz >/dev/null 2>&1; then
  info "Installing Oh My Zsh..."
  # Use curl with fail flag and show error if it fails
  if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
    printf "\033[1;31m[ERROR]\033[0m Failed to install Oh My Zsh\n" >&2
    exit 1
  fi
else
  info "Oh My Zsh is already installed"
fi

# if test ! $(which omz); then
#   info "Installing Oh My Zsh..."
#   /usr/bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# fi
rm -rf $HOME/.zshrc
ln -s $DOTFILES/zsh/.omarchy.zshrc $HOME/.zshrc

info "Setting up neovim..."
rm -rf $CONFIG_DIR/nvim
rm -rf $HOME/.local/share/nvim
ln -s $DOTFILES/nvim $CONFIG_DIR/nvim

info "Setting up git..."
ln -fs $DOTFILES/gitconfig $HOME/.gitconfig
# mkdir -p $HOME/.config/lazygit
# ln -fs $DOTFILES/lazygit/config.yml $HOME/.config/lazygit/config.yml

info "Setting up tmux..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -fs $DOTFILES/.tmux.conf $HOME/.tmux.conf
info "Remember to install the tmux plugins with prefix + I"

info "Setting up Ghostty"
# mkdir -p $CONFIG_DIR/ghostty
ln -sf $DOTFILES/ghostty $CONFIG_DIR/ghostty

info "All done! Please reboot your machine"
