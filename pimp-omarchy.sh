#!/usr/bin/bash

info() {
	printf "\033[0;34m[INFO]\033[0m %s\n" "$1"
}

warn() {
	printf "\033[0;33m[WARN]\033[0m %s\n" "$1"
}

error() {
	printf "\033[1;31m[ERROR]\033[0m %s\n" "$1" >&2
}

success() {
	printf "\033[0;32m[OK]\033[0m %s\n" "$1"
}

export DOTFILES="$HOME/Code/dotfiles/"
export CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$CONFIG_DIR"

info "Dotfiles path: $DOTFILES"
info "Config path: $CONFIG_DIR"

info "\nPimping up your Omarchy..."

info "Installing required packages..."
yay -S --noconfirm --needed zsh tmux tmux-plugin-manager opencode-bin lnav httpie github-cli nfs-utils \
	discord nordvpn-bin telegram-desktop-bin visual-studio-code-bin ttf-jetbrains-mono-nerd \
	slack-desktop discord go-task brave-bin yazi

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
		error "Failed to install Oh My Zsh"
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
ln -s $DOTFILES/lazygit $HOME/.config/lazygit

info "Setting up tmux..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -s $DOTFILES/.tmux.conf $HOME/.tmux.conf
info "Remember to install the tmux plugins with prefix + I"

info "Setting up Ghostty"
rm -rf $CONFIG_DIR/ghostty
ln -s $DOTFILES/ghostty $CONFIG_DIR/ghostty

info "Setting up Yazi..."
rm -rf $CONFIG_DIR/yazi
ln -s $DOTFILES/yazi $CONFIG_DIR/yazi

if command -v ya >/dev/null 2>&1; then
	info "Installing Yazi packages..."
	ya pkg install || warn "Failed to install Yazi packages"
else
	warn "Yazi package manager 'ya' was not found; skipping Yazi package install"
fi

info "All done! Please reboot your machine"
