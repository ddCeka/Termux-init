#!/data/data/com.termux/files/usr/bin/bash
set -e

#===========================================================
# Helpers
#===========================================================
msg() { echo -e "\n→ $1"; }
err() { echo "ERROR: $1" >&2; exit 1; }

backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.backup-$(date +%F)" 2>/dev/null || true
        msg "Backup created: ${file}.backup-$(date +%F)"
    fi
}

#===========================================================
# Update & Install Packages (Termux)
#===========================================================
msg "Updating packages"
pkg update -y >/dev/null
pkg upgrade -y >/dev/null

#===========================================================
# Ensure directories
#===========================================================
msg "Creating directory"
mkdir -p ~/.config/zsh
mkdir -p ~/.config/zsh/plugins

#===========================================================
# Change shell to ZSH (Termux-safe)
#===========================================================
msg "Setting ZSH as default shell"
chsh -s zsh || msg "chsh not supported, will start zsh manually"

#===========================================================
# Backup old zshrc and download new
#===========================================================
backup_file ~/.zshrc

msg "Downloading new zshrc"
curl -fsSL -o ~/.zshrc https://raw.githubusercontent.com/ddCeka/termux-init/master/zsh/zshrc

#===========================================================
# Install Powerlevel10k Theme
#===========================================================
msg "Installing Powerlevel10k theme"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.config/zsh/powerlevel10k >/dev/null 2>&1

curl -fsSL -o ~/.config/zsh/p10k.zsh https://raw.githubusercontent.com/ddCeka/termux-init/master/zsh/p10k.zsh

#===========================================================
# Install Plugins
#===========================================================
msg "Installing plugins"

git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/.config/zsh/plugins/fast-syntax-highlighting >/dev/null 2>&1
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.config/zsh/plugins/zsh-autosuggestions >/dev/null 2>&1
# this package also exist on termux-packages, idk which is more updated
git clone https://github.com/zsh-users/zsh-completions.git ~/.config/zsh/plugins/zsh-completions >/dev/null 2>&1

curl -fsSL -o ~/.config/zsh/plugins/completion.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/lib/completion.zsh
curl -fsSL -o ~/.config/zsh/plugins/history.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/lib/history.zsh
curl -fsSL -o ~/.config/zsh/plugins/key-bindings.zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/lib/key-bindings.zsh
curl -fsSL -o ~/.config/zsh/plugins/you-should-use.zsh https://raw.githubusercontent.com/MichaelAquilina/zsh-you-should-use/master/you-should-use.plugin.zsh

#===========================================================
# Install Aliases and Functions
#===========================================================
msg "Installing Aliases and Functions"
curl -fsSL -o ~/.config/zsh/aliases.zsh https://raw.githubusercontent.com/ddCeka/termux-init/master/zsh/aliases.zsh
curl -fsSL -o ~/.config/zsh/functions.zsh https://raw.githubusercontent.com/ddCeka/termux-init/master/zsh/functions.zsh

#===========================================================
# Update .zshrc sources
#===========================================================
cat << 'EOF' >> ~/.zshrc

# Custom additions (Termux)
source $HOME/.config/zsh/powerlevel10k/powerlevel10k.zsh-theme
source $HOME/.config/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $HOME/.config/zsh/plugins/completion.zsh
source $HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
source $HOME/.config/zsh/plugins/history.zsh
source $HOME/.config/zsh/plugins/key-bindings.zsh
source $HOME/.config/zsh/plugins/you-should-use.zsh
source $HOME/.config/zsh/plugins/zsh-assistant.zsh

# Aliases
source $HOME/.config/zsh/aliases.zsh

# Functions
source $HOME/.config/zsh/functions.zsh

EOF

#===========================================================
# Finish
#===========================================================
msg "Installation Finished!"
msg "→ Restart Termux or run: zsh"

#===========================================================
# Launch ZSH immediately
#===========================================================
exec zsh