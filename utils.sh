#!/bin/bash

# Function to check if a package is installed
is_installed() {
  pacman -Qi "$1" &> /dev/null
}

# Function to check if a package group is installed
is_group_installed() {
  pacman -Qg "$1" &> /dev/null
}

# Function to install packages if not already installed
install_packages() {
  local packages=("$@")
  local to_install=()

  for pkg in "${packages[@]}"; do
    if ! is_installed "$pkg" && ! is_group_installed "$pkg"; then
      to_install+=("$pkg")
    else
      echo "Not installing ${pkg}, because already installed."
    fi
  done

  if [ ${#to_install[@]} -ne 0 ]; then
    echo "Installing: ${to_install[*]}"
    yay -S --noconfirm "${to_install[@]}"
  fi
} 

install_packages_pacman() {
  local packages=("$@")
  local to_install=()

  for pkg in "${packages[@]}"; do
    if ! is_installed "$pkg" && ! is_group_installed "$pkg"; then
      to_install+=("$pkg")
    else
      echo "Not installing ${pkg}, because already installed."
    fi
  done

  if [ ${#to_install[@]} -ne 0 ]; then
    echo "Installing: ${to_install[*]}"
    sudo pacman -S --noconfirm "${to_install[@]}"
  fi
} 

uninstall_packages() {
  local packages=("$@")
  local to_uninstall=()

  for pkg in "${packages[@]}"; do
    if is_installed "$pkg" || is_group_installed "$pkg"; then
      to_uninstall+=("$pkg")
    else
      echo "Not uninstalling ${pkg}, because it is not installed."
    fi
  done

  if [ ${#to_install[@]} -ne 0 ]; then
    echo "Uninstalling: ${to_uninstall[*]}"
    yay -R --noconfirm "${to_uninstall[@]}"
  fi
} 
