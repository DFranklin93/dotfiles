#!/bin/bash

set -e

# Get the dotfiles repo root (parent of scripts/install directory)
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# ── Detect OS ───────────────────────────────────────────────────
. "$DOTFILES_ROOT/utils/detect_os.sh"

OS=$(detect_os)

echo "[*] Installing Neovim..."

# ── Install Neovim ──────────────────────────────────────────────
if ! command -v nvim >/dev/null 2>&1; then
    case "$OS" in
        arch)
            echo "[*] Installing Neovim via pacman..."
            sudo pacman -S --noconfirm --needed neovim
            ;;
        ubuntu|debian|linuxmint|pop)
            if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
                echo "[*] Running in container, installing Neovim via apt..."
                sudo apt-get update
                sudo apt-get install -y neovim
            else
                echo "[*] Installing Neovim via snap..."
                sudo snap install nvim --classic
            fi
            ;;
        wsl2)
            # snap requires systemd, which is enabled by default in modern WSL2
            # via /etc/wsl.conf (systemd=true). If you've disabled systemd,
            # fall back to: sudo apt-get install -y neovim
            echo "[*] Installing Neovim via snap (WSL2 + systemd)..."
            sudo snap install nvim --classic
            ;;
        *)
            echo "[!] Unsupported OS: $OS"
            exit 1
            ;;
    esac
else
    echo "[✓] Neovim already installed."
fi

# ── Install Dependencies ────────────────────────────────────────
echo "[*] Installing Neovim dependencies..."

# ── Node via nvm ────────────────────────────────────────────────
# apt's nodejs is pinned to 18.x on Ubuntu 22/24; Mason LSP packages
# (bash-language-server 5.x, vscode-langservers-extracted 4.x, etc.)
# require Node 20+. nvm gives us a current version without sudo and
# works identically on bare-metal Ubuntu and WSL2.
NVM_NODE_VERSION="22"
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

install_nvm_node() {
    # Remove apt-managed node/npm if present so they don't shadow nvm's
    if dpkg -s nodejs >/dev/null 2>&1; then
        echo "[*] Removing apt nodejs/npm (replacing with nvm)..."
        sudo apt-get remove -y nodejs npm
    fi

    if [ -s "$NVM_DIR/nvm.sh" ]; then
        echo "[✓] nvm already installed."
    else
        echo "[*] Installing nvm..."
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    fi

    # Load nvm into this shell session
    # shellcheck disable=SC1091
    . "$NVM_DIR/nvm.sh"

    if nvm ls "$NVM_NODE_VERSION" | grep -q "v$NVM_NODE_VERSION"; then
        echo "[✓] Node $NVM_NODE_VERSION already installed via nvm."
    else
        echo "[*] Installing Node $NVM_NODE_VERSION via nvm..."
        nvm install "$NVM_NODE_VERSION"
    fi

    nvm alias default "$NVM_NODE_VERSION"
    nvm use default
    echo "[✓] Node $(node --version) / npm $(npm --version) active."
}

case "$OS" in
    arch)
        for pkg in nodejs npm python; do
            if ! pacman -Qi "$pkg" &>/dev/null; then
                echo "Installing $pkg..."
                sudo pacman -S --noconfirm --needed "$pkg"
            else
                echo "[✓] $pkg already installed."
            fi
        done
        ;;
    ubuntu|debian|linuxmint|pop|wsl2)
        install_nvm_node
        # python3 still comes from apt
        if ! dpkg -s python3 >/dev/null 2>&1; then
            echo "Installing python3..."
            sudo apt-get install -y python3
        else
            echo "[✓] python3 already installed."
        fi
        ;;
esac

# ── Symlink Neovim Config ───────────────────────────────────────
echo "[*] Setting up Neovim config..."

mkdir -p ~/.config

if [ -L ~/.config/nvim ] && [ "$(readlink ~/.config/nvim)" = "$DOTFILES_ROOT/.config/nvim" ]; then
    echo "[✓] Neovim config symlink already exists."
else
    echo "[*] Linking Neovim config..."
    ln -sf "$DOTFILES_ROOT/.config/nvim" ~/.config/nvim
fi

# ── Bootstrap lazy.nvim ─────────────────────────────────────────
LAZY_PATH="$HOME/.local/share/nvim/site/pack/lazy/start/lazy.nvim"
if [ -d "$LAZY_PATH" ]; then
    echo "[✓] lazy.nvim already installed."
else
    echo "[*] Installing lazy.nvim plugin manager..."
    git clone https://github.com/folke/lazy.nvim.git "$LAZY_PATH"
fi

# ── Sync Plugins ────────────────────────────────────────────────
echo "[*] Syncing Neovim plugins..."
nvim --headless "+Lazy sync" +qa

echo "[*] Building Treesitter parsers..."
nvim --headless "+TSUpdate" +qa

echo "[✓] Neovim setup complete."
