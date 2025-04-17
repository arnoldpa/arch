#!/bin/bash

# ================
# Copied, inspired and adapted from https://github.com/typecraft-dev/crucible
# ================

clear
# Exit on any error
set -e
# Source utility functions
source utils.sh

# Source the package list
if [ ! -f "packages.conf" ]; then
  echo "Error: packages.conf not found!"
  exit 1
fi

source packages.conf

echo "Starting system setup..."

echo "Configure pacman..."
PACMAN_CONF="/etc/pacman.conf"
if grep -q "^#Color" "$PACMAN_CONF"; then
    sudo sed -i "s/^#Color/Color/" "$PACMAN_CONF"
fi
if grep -q "^ParallelDownloads = 5" "$PACMAN_CONF"; then
    sudo sed -i "s/^ParallelDownloads = 5/ParallelDownloads = 20/" "$PACMAN_CONF"
fi

echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install yay AUR helper if not present
if ! command -v yay &> /dev/null; then
  echo "Installing yay AUR helper..."
  sudo pacman -S --needed git base-devel --noconfirm
  cd ~/Applications/
  git clone https://aur.archlinux.org/yay.git
  cd yay
  echo "building yay..."
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  echo "yay is already installed"
fi

echo "Add DE locale..."
DE_LOCALE="de_DE.UTF-8 UTF-8"
LOCALE_FILE="/etc/locale.gen"
if grep -q "^#${DE_LOCALE}" "$LOCALE_FILE"; then
    sudo sed -i "s/^#${DE_LOCALE}/${DE_LOCALE}/" "$LOCALE_FILE"
    sudo locale-gen
else
    echo "DE already installed"
fi

echo "Hide GRUB menu..."
GRUB_FILE="/etc/default/grub"
if grep -q "^GRUB_TIMEOUT_STYLE=menu" "$GRUB_FILE"; then
    sudo sed -i "s/^GRUB_TIMEOUT_STYLE=menu/GRUB_TIMEOUT_STYLE=hidden/" "$GRUB_FILE"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "GRUB menu already hidden"
fi

# Install packages by category
echo "Installing system utilities..."
install_packages "${SYSTEM_UTILS[@]}"

echo "Installing development tools..."
install_packages "${DEV_TOOLS[@]}"

echo "Installing system maintenance tools..."
install_packages "${MAINTENANCE[@]}"

echo "Installing desktop environment..."
install_packages_pacman "${DESKTOP[@]}"

echo "Installing media packages..."
install_packages "${MEDIA[@]}"

echo "Installing fonts..."
install_packages "${FONTS[@]}"

echo "Configuring services..."
for service in "${SERVICES[@]}"; do
  if ! systemctl is-enabled "$service" &> /dev/null; then
    echo "Enabling $service..."
    sudo systemctl enable "$service"
  else
    echo "$service is already enabled"
  fi
done

# Install gnome specific things
echo "Installing Gnome extensions..."
. gnome/gnome-extensions.sh
echo "Setting Gnome hotkeys..."
. gnome/gnome-hotkeys.sh
echo "Configuring Gnome..."
. gnome/gnome-settings.sh

echo "Installing flatpaks..."
. install-flatpaks.sh

echo "Remove unneeded dependencies..."
yay -Yc --noconfirm

echo "Setup complete! You may want to reboot your system."
