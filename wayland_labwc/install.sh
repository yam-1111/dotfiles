#!/bin/bash

############ Helper Functions ############

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a package is installed
is_installed() {
    pacman -Q "$1" &>/dev/null
}

# Function to install yay if not installed
install_yay() {
    if ! command_exists yay; then
        echo "[*] yay is not installed. Installing yay..."
        sudo pacman -S --needed git base-devel --noconfirm
        git clone https://aur.archlinux.org/yay-bin.git
        cd yay-bin || exit
        makepkg -si --noconfirm
        cd ..
        rm -rf yay-bin
    else
        echo "[!] yay is already installed."
    fi
}

# Function to install a package (prefers pacman, falls back to yay)
install_package() {
    local package=$1

    # Check if the package is already installed
    if is_installed "$package"; then
        echo "[Note] $package is already installed. Skipping..."
        return
    fi

    # Check if the package exists in pacman
    if pacman -Si "$package" &>/dev/null; then
        echo "[*] Installing $package using pacman..."
        sudo pacman -S --noconfirm --needed "$package"

    # Check if the package exists in yay
    elif yay -Si "$package" &>/dev/null; then
        echo "$package is available in AUR."
        read -rp "[y/n] Do you want to install $package? This may take a while (y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo "--Installing $package using yay...--"
            yay -S --noconfirm "$package"
        else
            echo "[Note] Skipping $package."
        fi

    else
        echo "[!] Package $package not found in pacman or AUR. Skipping..."
    fi
}


############ Install yay if not present ############
install_yay

############ Install auto-cpufreq ############
if ! command_exists auto-cpufreq; then
    echo "auto-cpufreq is not installed. Installing..."
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git
    cd auto-cpufreq || exit
    sudo ./auto-cpufreq-installer
    cd ..
    rm -rf auto-cpufreq
else
    echo "auto-cpufreq is already installed!"
fi

############ Install Required Packages ############
packages=(
    "python"
    "labwc"
    "waybar"
    "rofi"
    "thunar"
    "visual-studio-code-bin"  
    "microsoft-edge-stable-bin"
    "okular"
    "spotify"
    "gedit"
    "blueman"  
    "obsidian"
    "vlc"
    "mpv"
    "pavucontrol"
    "zen-browser-bin"  
    "localsend-bin"
    "nomacs"
    "bemoji"
    "ttf-apple-emoji"
    "ttf-font-awesome"
    "ttf-inter"
    "ttf-ms-fonts"
    "ttf-roboto"
    "noto-fonts"
    "nmap"
)
sudo pacman -Sy && yay -Sy
for package in "${packages[@]}"; do
   
    install_package "$package"
done

############ Copy system files          ############
BASH_PROFILE="$HOME/.bash_profile"
CONTENT='[[ -f ~/.bashrc ]] && . ~/.bashrc

if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
    exec labwc
fi'

if [[ ! -f "$BASH_PROFILE" ]]; then
    echo "[*] Creating ~/.bash_profile..."
    echo -e "$CONTENT" > "$BASH_PROFILE"
else
    if ! grep -Fxq "[[ -f ~/.bashrc ]] && . ~/.bashrc" "$BASH_PROFILE"; then
        echo "Appending content to ~/.bash_profile..."
        echo -e "$CONTENT" >> "$BASH_PROFILE"
    else
        echo "[!] Content already exists in ~/.bash_profile."
    fi
fi

echo "==== Installation complete. ===="

