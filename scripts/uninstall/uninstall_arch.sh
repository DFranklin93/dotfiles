#!/bin/bash

set -e

# ── Paths ────────────────────────────────────────────────────────
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="$DOTFILES_ROOT/scripts"
CONFIG_DIR="$HOME/.config"

# ── Detect VM ───────────────────────────────────────────────────
IS_VM=false
if systemd-detect-virt --quiet; then
    IS_VM=true
    echo "[*] Virtual machine detected: $(systemd-detect-virt)"
else
    echo "[*] Bare metal detected"
fi

# ── Feature Flags ───────────────────────────────────────────────
UNINSTALL_BASE=true
UNINSTALL_FONTS=true
UNINSTALL_DOCKER=true
UNINSTALL_NVIM=true
UNINSTALL_HYPRLAND=true

# ── Parse Args ──────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-base)        UNINSTALL_BASE=false;      shift ;;
        --skip-fonts)       UNINSTALL_FONTS=false;     shift ;;
        --skip-docker)      UNINSTALL_DOCKER=false;    shift ;;
        --skip-nvim)        UNINSTALL_NVIM=false;      shift ;;
        --skip-hyprland)    UNINSTALL_HYPRLAND=false;  shift ;;
        --only-base)
            UNINSTALL_FONTS=false; UNINSTALL_DOCKER=false
            UNINSTALL_NVIM=false; UNINSTALL_HYPRLAND=false
            shift ;;
        --only-fonts)
            UNINSTALL_BASE=false; UNINSTALL_DOCKER=false
            UNINSTALL_NVIM=false; UNINSTALL_HYPRLAND=false
            shift ;;
        --only-docker)
            UNINSTALL_BASE=false; UNINSTALL_FONTS=false
            UNINSTALL_NVIM=false; UNINSTALL_HYPRLAND=false
            shift ;;
        --only-nvim)
            UNINSTALL_BASE=false; UNINSTALL_FONTS=false
            UNINSTALL_DOCKER=false; UNINSTALL_HYPRLAND=false
            shift ;;
        --only-hyprland)
            UNINSTALL_BASE=false; UNINSTALL_FONTS=false
            UNINSTALL_DOCKER=false; UNINSTALL_NVIM=false
            shift ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-base         Skip base tools removal"
            echo "  --skip-fonts        Skip font removal"
            echo "  --skip-docker       Skip Docker removal"
            echo "  --skip-nvim         Skip Neovim removal"
            echo "  --skip-hyprland     Skip Hyprland removal"
            echo "  --only-base         Remove only base tools"
            echo "  --only-fonts        Remove only fonts"
            echo "  --only-docker       Remove only Docker"
            echo "  --only-nvim         Remove only Neovim"
            echo "  --only-hyprland     Remove only Hyprland configs and packages"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                          # Remove everything"
            echo "  $0 --skip-docker            # Remove everything except Docker"
            echo "  $0 --only-hyprland          # Only remove Hyprland configs and symlinks"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo ""
echo "[*] Starting Arch uninstallation with flags:"
echo "    UNINSTALL_BASE=$UNINSTALL_BASE"
echo "    UNINSTALL_FONTS=$UNINSTALL_FONTS"
echo "    UNINSTALL_DOCKER=$UNINSTALL_DOCKER"
echo "    UNINSTALL_NVIM=$UNINSTALL_NVIM"
echo "    UNINSTALL_HYPRLAND=$UNINSTALL_HYPRLAND"
echo "    IS_VM=$IS_VM"
echo ""

# ── Helper: Remove symlink if managed by dotfiles ───────────────
remove_symlink() {
    local dst="$1"
    if [ -L "$dst" ]; then
        TARGET=$(readlink "$dst")
        if [[ "$TARGET" == "$DOTFILES_ROOT"* ]]; then
            echo "Removing symlink $dst"
            rm "$dst"
        else
            echo "[!] $dst is a symlink but not managed by dotfiles. Skipping."
        fi
    elif [ -e "$dst" ]; then
        echo "[!] $dst is not a symlink. Skipping to avoid data loss."
    else
        echo "[✓] $dst not found. Nothing to remove."
    fi
}

# ── Helper: Remove pacman package if installed ──────────────────
pacman_remove() {
    local pkg="$1"
    if pacman -Qi "$pkg" &>/dev/null; then
        echo "Removing $pkg..."
        sudo pacman -Rns --noconfirm "$pkg" 2>/dev/null || true
    else
        echo "[✓] $pkg not installed."
    fi
}

# ── Base Tools ──────────────────────────────────────────────────
if [ "$UNINSTALL_BASE" = "true" ]; then
    echo "[*] Removing base tools..."
    BASE_PACKAGES=(
        git curl zsh tmux
        wl-clipboard xclip
        base-devel networkmanager
    )
    read -p "[?] Remove base tools? This may affect other applications. (y/N) " REMOVE_BASE
    if [ "$REMOVE_BASE" = "y" ]; then
        for pkg in "${BASE_PACKAGES[@]}"; do
            pacman_remove "$pkg"
        done
    else
        echo "[⊘] Skipping base tools removal"
    fi
else
    echo "[⊘] Skipping base tools removal"
fi

# ── Fonts ───────────────────────────────────────────────────────
if [ "$UNINSTALL_FONTS" = "true" ]; then
    echo "[*] Running font uninstaller..."
    bash "$SCRIPTS_DIR/uninstall/uninstall_firacode_nerd_font.sh"
else
    echo "[⊘] Skipping font removal"
fi

# ── Docker ──────────────────────────────────────────────────────
if [ "$UNINSTALL_DOCKER" = "true" ]; then
    echo "[*] Running Docker uninstaller..."
    bash "$SCRIPTS_DIR/uninstall/uninstall_docker.sh"
else
    echo "[⊘] Skipping Docker removal"
fi

# ── Neovim ──────────────────────────────────────────────────────
if [ "$UNINSTALL_NVIM" = "true" ]; then
    echo "[*] Running Neovim uninstaller..."
    bash "$SCRIPTS_DIR/uninstall/uninstall_nvim.sh"
else
    echo "[⊘] Skipping Neovim removal"
fi

# ── Hyprland ────────────────────────────────────────────────────
if [ "$UNINSTALL_HYPRLAND" = "true" ]; then
    echo "[*] Removing Hyprland and desktop environment..."

    # ── Remove config symlinks ──────────────────────────────────
    echo "[*] Removing config symlinks..."
    remove_symlink "$CONFIG_DIR/hypr/hyprland.conf"
    remove_symlink "$CONFIG_DIR/waybar/config"
    remove_symlink "$CONFIG_DIR/waybar/style.css"
    remove_symlink "$CONFIG_DIR/mako/config"
    remove_symlink "$CONFIG_DIR/swaylock/config"
    remove_symlink "$CONFIG_DIR/kitty"

    # ── Remove script symlinks ──────────────────────────────────
    echo "[*] Removing script symlinks..."
    remove_symlink "$HOME/lock.sh"
    remove_symlink "$HOME/screenshot.sh"
    remove_symlink "$HOME/start-wallpaper.sh"

    # ── VM-specific cleanup ─────────────────────────────────────
    if [ "$IS_VM" = "true" ]; then
        echo "[*] Removing VM-specific setup..."
        remove_symlink "$HOME/wayland-to-x11-clip.sh"

        if systemctl is-enabled vboxservice &>/dev/null; then
            echo "[*] Disabling vboxservice..."
            sudo systemctl disable --now vboxservice
        else
            echo "[✓] vboxservice not enabled."
        fi

        if [ -f /etc/modules-load.d/virtualbox.conf ]; then
            echo "[*] Removing VirtualBox modules config..."
            sudo rm /etc/modules-load.d/virtualbox.conf
        else
            echo "[✓] VirtualBox modules config not found."
        fi
    fi

    # ── Remove Hyprland packages ────────────────────────────────
    read -p "[?] Remove Hyprland packages? This will remove the desktop environment. (y/N) " REMOVE_PKGS
    if [ "$REMOVE_PKGS" = "y" ]; then
        echo "[*] Removing Hyprland packages..."
        HYPR_PACKAGES=(
            hyprland waybar wofi kitty
            xdg-desktop-portal-hyprland
            polkit-kde-agent qt5-wayland qt6-wayland
            pipewire pipewire-pulse wireplumber
            grim slurp wl-clipboard
            mako libnotify
            swaylock swaybg
            thunar thunar-volman thunar-archive-plugin gvfs
            imv xorg-xwayland cliphist
            ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
        )

        for pkg in "${HYPR_PACKAGES[@]}"; do
            pacman_remove "$pkg"
        done

        # Remove VM packages if applicable
        if [ "$IS_VM" = "true" ]; then
            echo "[*] Removing VM packages..."
            VM_PACKAGES=(
                virtualbox-guest-utils
                xclip
            )
            for pkg in "${VM_PACKAGES[@]}"; do
                pacman_remove "$pkg"
            done
        fi

        # Clean orphans
        ORPHANS=$(pacman -Qdtq 2>/dev/null)
        if [ -n "$ORPHANS" ]; then
            echo "[*] Removing orphaned packages..."
            sudo pacman -Rns --noconfirm $ORPHANS
        else
            echo "[✓] No orphaned packages."
        fi
    else
        echo "[⊘] Skipping package removal"
    fi

    echo "[✓] Hyprland removal complete"
else
    echo "[⊘] Skipping Hyprland removal"
fi

echo ""
echo "[✓] Arch uninstallation complete."
