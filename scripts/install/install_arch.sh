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
INSTALL_BASE=true
INSTALL_FONTS=true
INSTALL_DOCKER=true
INSTALL_NVIM=true
INSTALL_HYPRLAND=true

# ── Parse Args ──────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-base)        INSTALL_BASE=false;      shift ;;
        --skip-fonts)       INSTALL_FONTS=false;     shift ;;
        --skip-docker)      INSTALL_DOCKER=false;    shift ;;
        --skip-nvim)        INSTALL_NVIM=false;      shift ;;
        --skip-hyprland)    INSTALL_HYPRLAND=false;  shift ;;
        --only-base)
            INSTALL_FONTS=false; INSTALL_DOCKER=false
            INSTALL_NVIM=false; INSTALL_HYPRLAND=false
            shift ;;
        --only-fonts)
            INSTALL_BASE=false; INSTALL_DOCKER=false
            INSTALL_NVIM=false; INSTALL_HYPRLAND=false
            shift ;;
        --only-docker)
            INSTALL_BASE=false; INSTALL_FONTS=false
            INSTALL_NVIM=false; INSTALL_HYPRLAND=false
            shift ;;
        --only-nvim)
            INSTALL_BASE=false; INSTALL_FONTS=false
            INSTALL_DOCKER=false; INSTALL_HYPRLAND=false
            shift ;;
        --only-hyprland)
            INSTALL_BASE=false; INSTALL_FONTS=false
            INSTALL_DOCKER=false; INSTALL_NVIM=false
            shift ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-base         Skip base tools installation"
            echo "  --skip-fonts        Skip font installation"
            echo "  --skip-docker       Skip Docker installation (also skipped on VMs)"
            echo "  --skip-nvim         Skip Neovim installation"
            echo "  --skip-hyprland     Skip Hyprland installation"
            echo "  --only-base         Install only base tools"
            echo "  --only-fonts        Install only fonts"
            echo "  --only-docker       Install only Docker"
            echo "  --only-nvim         Install only Neovim"
            echo "  --only-hyprland     Install only Hyprland and desktop configs"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                          # Install everything"
            echo "  $0 --skip-docker            # Install everything except Docker"
            echo "  $0 --only-hyprland          # Only symlink Hyprland configs and scripts"
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
echo "[*] Starting Arch installation with flags:"
echo "    INSTALL_BASE=$INSTALL_BASE"
echo "    INSTALL_FONTS=$INSTALL_FONTS"
echo "    INSTALL_DOCKER=$INSTALL_DOCKER"
echo "    INSTALL_NVIM=$INSTALL_NVIM"
echo "    INSTALL_HYPRLAND=$INSTALL_HYPRLAND"
echo "    IS_VM=$IS_VM"
echo ""

# ── Helper: Install pacman package if missing ───────────────────
pacman_install() {
    local pkg="$1"
    if ! pacman -Qi "$pkg" &>/dev/null; then
        echo "Installing $pkg..."
        sudo pacman -S --noconfirm --needed "$pkg"
    else
        echo "[✓] $pkg already installed."
    fi
}

# ── Helper: Symlink with backup ─────────────────────────────────
symlink_config() {
    local src="$1"
    local dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "[✓] Symlink already exists: $dst"
        return
    fi
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "[!] Backing up existing $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sf "$src" "$dst"
    echo "[✓] Linked: $dst → $src"
}

# ── Base Tools ──────────────────────────────────────────────────
if [ "$INSTALL_BASE" = "true" ]; then
    echo "[*] Installing base tools..."
    BASE_PACKAGES=(
        git curl zsh tmux
        wl-clipboard xclip
        base-devel networkmanager
    )
    for pkg in "${BASE_PACKAGES[@]}"; do
        pacman_install "$pkg"
    done
else
    echo "[⊘] Skipping base tools installation"
fi

# ── Fonts ───────────────────────────────────────────────────────
if [ "$INSTALL_FONTS" = "true" ]; then
    echo "[*] Running font installer..."
    bash "$SCRIPTS_DIR/install/install_firacode_nerd_font.sh"
else
    echo "[⊘] Skipping font installation"
fi

# ── Docker ──────────────────────────────────────────────────────
if [ "$INSTALL_DOCKER" = "true" ]; then
    echo "[*] Running Docker installer..."
    bash "$SCRIPTS_DIR/install/install_docker.sh"
else
    echo "[⊘] Skipping Docker installation"
fi

# ── Neovim ──────────────────────────────────────────────────────
if [ "$INSTALL_NVIM" = "true" ]; then
    echo "[*] Running Neovim installer..."
    bash "$SCRIPTS_DIR/install/install_nvim.sh"
else
    echo "[⊘] Skipping Neovim installation"
fi

# ── Hyprland ────────────────────────────────────────────────────
if [ "$INSTALL_HYPRLAND" = "true" ]; then
    echo "[*] Installing Hyprland and desktop environment..."

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
        pacman_install "$pkg"
    done

    # ── Symlink Hyprland configs ────────────────────────────────
    echo "[*] Symlinking Hyprland configs..."
    symlink_config "$DOTFILES_ROOT/.config/hypr/hyprland.conf"  "$CONFIG_DIR/hypr/hyprland.conf"
    symlink_config "$DOTFILES_ROOT/.config/waybar/config"        "$CONFIG_DIR/waybar/config"
    symlink_config "$DOTFILES_ROOT/.config/waybar/style.css"     "$CONFIG_DIR/waybar/style.css"
    symlink_config "$DOTFILES_ROOT/.config/mako/config"          "$CONFIG_DIR/mako/config"
    symlink_config "$DOTFILES_ROOT/.config/swaylock/config"      "$CONFIG_DIR/swaylock/config"
    symlink_config "$DOTFILES_ROOT/.config/kitty"                "$CONFIG_DIR/kitty"

    # ── Symlink shared arch scripts ─────────────────────────────
    echo "[*] Symlinking scripts..."
    chmod +x "$SCRIPTS_DIR/arch/lock.sh"
    chmod +x "$SCRIPTS_DIR/arch/screenshot.sh"
    symlink_config "$SCRIPTS_DIR/arch/lock.sh"       "$HOME/lock.sh"
    symlink_config "$SCRIPTS_DIR/arch/screenshot.sh" "$HOME/screenshot.sh"

    # ── VM-specific setup ───────────────────────────────────────
    if [ "$IS_VM" = "true" ]; then
        echo "[*] Applying VM-specific setup..."

        VM_PACKAGES=(
            virtualbox-guest-utils
            xclip
        )
        for pkg in "${VM_PACKAGES[@]}"; do
            pacman_install "$pkg"
        done

        # Enable VirtualBox guest services
        if ! systemctl is-enabled vboxservice &>/dev/null; then
            echo "[*] Enabling vboxservice..."
            sudo systemctl enable --now vboxservice
        else
            echo "[✓] vboxservice already enabled."
        fi

        # Load vbox kernel modules
        sudo modprobe -a vboxguest vboxsf vboxvideo 2>/dev/null || true

        # Persist modules on boot
        if [ ! -f /etc/modules-load.d/virtualbox.conf ]; then
            echo -e "vboxguest\nvboxsf\nvboxvideo" | sudo tee /etc/modules-load.d/virtualbox.conf
            echo "[✓] VirtualBox kernel modules configured."
        else
            echo "[✓] VirtualBox modules config already exists."
        fi

        # Symlink VM-specific scripts
        chmod +x "$SCRIPTS_DIR/arch/virtual_machine/wayland-to-x11-clip.sh"
        chmod +x "$SCRIPTS_DIR/arch/virtual_machine/start-wallpaper.sh"
        symlink_config "$SCRIPTS_DIR/arch/virtual_machine/wayland-to-x11-clip.sh" "$HOME/wayland-to-x11-clip.sh"
        symlink_config "$SCRIPTS_DIR/arch/virtual_machine/start-wallpaper.sh"     "$HOME/start-wallpaper.sh"

        echo "[✓] VM setup complete"

    # ── Bare metal setup ────────────────────────────────────────
    else
        echo "[*] Applying bare metal setup..."

        chmod +x "$SCRIPTS_DIR/arch/start-wallpaper.sh"
        symlink_config "$SCRIPTS_DIR/arch/start-wallpaper.sh" "$HOME/start-wallpaper.sh"

        echo ""
        echo "[!] Bare metal checklist — manual steps required:"
        echo "    1. Set your wallpaper path in ~/start-wallpaper.sh"
        echo "    2. Set your network interface in ~/.config/waybar/config"
        echo "    3. Remove VM-only lines from ~/.config/hypr/hyprland.conf:"
        echo "         env = WLR_NO_HARDWARE_CURSORS,1"
        echo "         env = WLR_RENDERER_ALLOW_SOFTWARE,1"
        echo "         env = LIBGL_ALWAYS_SOFTWARE,1"
        echo "         env = WLR_BACKENDS,x11"
        echo "         exec-once = sleep 2 && pkill VBoxClient; true"
        echo "         exec-once = sleep 3 && VBoxClient --clipboard"
        echo "         exec = pkill -f wayland-to-x11-clip.sh; sleep 4 && /home/\$USER/wayland-to-x11-clip.sh"
        echo "    4. Install GPU drivers for your hardware"
        echo "    5. Run 'hyprctl reload' after making changes"
    fi

    echo "[✓] Hyprland setup complete"
else
    echo "[⊘] Skipping Hyprland installation"
fi

echo ""
echo "[✓] Arch setup complete."
