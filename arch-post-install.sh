#!/usr/bin/env bash
set -e

# =========================
# Arch Post-Install Script (Version 1.0.13)
# Single-line package arrays
# Clean section spacing and package previews
# =========================

# --- Colors ---
GREEN='\033[0;32m'    # Section headers
YELLOW='\033[1;33m'   # Action/info messages
NC='\033[0m'          # Reset color

# =========================
# Helper Functions
# =========================

# Print section header with leading newline
print_header() {
    echo -e "\n${GREEN}==> $1${NC}"
}

# Info messages
print_info() {
    echo -e "${YELLOW}--> $1${NC}"
}

# Prompt user with package preview before install
ask_with_packages() {
    local question="$1"
    shift
    local pkgs=("$@")

    echo ""
    echo "$question"
    echo "Packages: ${pkgs[*]}"
    read -rp "Proceed? (y/N): " response

    [[ "$response" =~ ^[Yy]$ ]]
}

# Install packages via pacman
install_pkgs() {
    sudo pacman -S --needed --noconfirm "$@"
}

# Install a named section of packages
install_section() {
    local section_name="$1"
    shift
    print_header "Installing: $section_name"
    install_pkgs "$@"
    print_info "Completed: $section_name"
}

# Update system packages
update_system() {
    print_header "Updating system (pacman -Syu)"
    sudo pacman -Syu --noconfirm
    print_info "System is up to date"
}

# =========================
# Main Execution Flow
# =========================
echo "===================================="
echo " Arch Post-Install Script (Template)"
echo "===================================="

# Update system first
update_system

# =====================
# Essential Utilities
# =====================
ESSENTIAL_PKGS=(git github-cli wget curl htop fastfetch less unzip zip man-db man-pages bash-completion python tk reflector)
if ask_with_packages "Install Essential Utilities?" "${ESSENTIAL_PKGS[@]}"; then
    install_section "Essential Utilities" "${ESSENTIAL_PKGS[@]}"
else
    print_info "Skipping Essential Utilities"
fi

# =====================
# Terminal & CLI Tools
# =====================
TERMINAL_PKGS=(kitty micro wl-clipboard xclip bat tree)
if ask_with_packages "Install Terminal & CLI Tools?" "${TERMINAL_PKGS[@]}"; then
    install_section "Terminal & CLI Tools" "${TERMINAL_PKGS[@]}"
else
    print_info "Skipping Terminal & CLI Tools"
fi

# =====================
# Neovim Environment
# =====================
NEOVIM_PKGS=(neovim ripgrep fd tree-sitter nodejs npm)
if ask_with_packages "Install Neovim and supporting tools?" "${NEOVIM_PKGS[@]}"; then
    install_section "Neovim Environment" "${NEOVIM_PKGS[@]}"
else
    print_info "Skipping Neovim Environment"
fi

# ======================
# Kate (Advanced Editor)
# ======================
# markdownpart required for Markdown preview in Kate
KATE_PKGS=(kate markdownpart)
if ask_with_packages "Install Kate with Markdown preview support?" "${KATE_PKGS[@]}"; then
    install_section "Kate (Advanced Editor)" "${KATE_PKGS[@]}"
else
    print_info "Skipping Kate (Advanced Editor)"
fi

# =====================
# Multimedia Codecs
# =====================
MULTIMEDIA_PKGS=(ffmpeg vlc mpv gst-libav gst-plugins-good gst-plugins-bad gst-plugins-ugly)
if ask_with_packages "Install Multimedia Codecs and playback support?" "${MULTIMEDIA_PKGS[@]}"; then
    install_section "Multimedia Codecs" "${MULTIMEDIA_PKGS[@]}"
else
    print_info "Skipping Multimedia Codecs"
fi

# =====================
# Fonts
# =====================
FONTS_PKGS=(ttf-liberation ttf-firacode-nerd ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-sourcecodepro-nerd)
if ask_with_packages "Install system and coding fonts?" "${FONTS_PKGS[@]}"; then
    install_section "Fonts" "${FONTS_PKGS[@]}"
else
    print_info "Skipping Fonts"
fi

# =====================
# Breeze Themes & Icons
# =====================
BREEZE_PKGS=(breeze breeze-icons breeze-gtk)
if ask_with_packages "Install Breeze themes and icons (recommended for KDE apps)?" "${BREEZE_PKGS[@]}"; then
    install_section "Breeze Themes & Icons" "${BREEZE_PKGS[@]}"
else
    print_info "Skipping Breeze Themes & Icons"
fi

# =====================
# Web Browsers
# =====================
WEB_BROWSERS_PKGS=(firefox chromium)
if ask_with_packages "Install Web Browsers?" "${WEB_BROWSERS_PKGS[@]}"; then
    install_section "Web Browsers" "${WEB_BROWSERS_PKGS[@]}"
else
    print_info "Skipping Web Browsers"
fi

# =====================
# Script Completion
# =====================
print_header "Post-install base setup complete"

