# Install arch 

## Install from live device
- Additaional packages: `vim git linux-headers glib2-devel base-devel unzip fastfetch bc`
- Reboot
- Make sure system is latest: `sudo pacman -Syu`

## Install "de" locale
- `sudo vim /etc/locale.gen`
- `sudo locale-gen`

## Configure pacman
- `sudo vim /etc/pacman.conf`

## Configure GRUB
- Dont show GRUB on startup -> `GRUB_TIMEOUT_STYLE=hidden`
- `sudo vim /etc/default/grub`
- `sudo grub-mkconfig -o /boot/grub/grub.cfg`

## Nvida via nvidia-all
- ```
  # Directory
  mkdir Applications
  cd Applications/

  # Nvidia-all
  git clone https://github.com/Frogging-Family/nvidia-all.git
  cd nvidia-all/
  makepkg -si

  # Nvidia services
  sudo systemctl enable nvidia-suspend.service
  sudo systemctl enable nvidia-hibernate.service
  sudo systemctl enable nvidia-resume.service

  # Modeprobe Nvidia
  sudo vim /etc/modprobe.d/nvidia.conf
  # CONTENT
  options nvidia_drm modeset=1
  options nvidia_drm fbdev=1
  options nvidia NVreg_PreserveVideoMemoryAllocations=1
  NVreg_TemporaryFilePath=/var/tmp
  # END CONTENT

  # Fore good messure
  sudo grub-mkconfig -o /boot/grub/grub.cfg

  # Early as possible loading
  sudo vim /etc/mkinitcpio.conf
  # CONTENT
  MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
  BINARIES=()
  FILES=()
  HOOKS=(base udev autodetect microcode keyboard keymap modconf block filesystems fsck)
  
  # COMPRESSION
  COMPRESSION=(lz4)
  
  # COMPRESSION_OPTIONS
  # Additional options for the compressor
  COMPRESSION_OPTIONS=(-9)
  # END CONTENT

  sudo mkinitcpio -P

  # pacman hook
  sudo mkdir /etc/pacman.d/hooks
  sudo vim /etc/pacman.d/hooks/nvidia.hook
  # CONTENT
  [Trigger]
  Operation=Install
  Operation=Upgrade
  Operation=Remove
  Type=Package
  # Uncomment the installed NVIDIA package
  Target=nvidia
  #Target=nvidia-open
  #Target=nvidia-lts
  # If running a different kernel, modify below to match
  Target=linux
  
  [Action]
  Description=Updating NVIDIA module in initcpio
  Depends=mkinitcpio
  When=PostTransaction
  NeedsTargets
  Exec=/bin/sh -c 'while read -r trg; do case $trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
  # END CONTENT

  # Nvidia persitence settings
  https://docs.nvidia.com/deploy/driver-persistence/index.html#usage
  sudo nvidia-persistenced --user [[USER]]

  # Check nvidia is working
  nvidia-smi

  # More infos:
  https://getcryst.al/site/docs/crystal-linux/nvidiawayland
  
  ```

## Gnome
- https://forum.endeavouros.com/t/enable-wayland-gnome-gdm-with-nvidia-and-make-gestures-suspend-work/31621
- https://getcryst.al/site/docs/crystal-linux/nvidiawayland
- Installation: `sudo pacman -S gnome`
- Force Wayland: `sudo ln -s /dev/null /etc/udev/rules.d/61-gdm.rules`
- Environment: `sudo vim /etc/environment`
  ```
  GBM_BACKEND=nvidia-drm
  __GLX_VENDOR_LIBRARY_NAME=nvidia
  ```  
- Single start: `sudo systemctl start gdm.service`
- Check Wayland: `loginctl show-session `loginctl|grep <YOUR_USER_NAME>|awk '{print $1}'` -p Type`
- Enable autostart: `sudo systemctl enable gdm.service`

## YAY
- ```
  cd ~/Applications/
  git clone https://aur.archlinux.org/yay.git
  cd yay/
  makepkg -si
  ```
## Gnome extensions
- `sudo pacman -S gnome-tweaks`
- `yay -S extension-manager`
- Blur my Shell
- Dash to Dock
- Forge (Disabled - Tiling)
- Unblank lock screen
- Wayland or X11

## Jetbrains nerd font
- ```
  cd ~/.local/share/
  mkdir -p fonts/jetbrains-nerd-fonts
  cd fonts/jetbrains-nerd-fonts
  cp ~/Downloads/JetBrainsMono.zip .
  unzip JetBrainsMono.zip
  sudo fc-cache -vf
  ```
- Find font: `fc-list : family style | grep "JetBrainsMono Nerd"`

## Chromium
- `sudo pacman -S chromium`

## Remove some default gnome apps
- TBD
 
## Gnome weather
- Download and use https://gitlab.com/julianfairfax/scripts/-/blob/main/add-location-to-gnome-weather.sh
- `bc` needs to be installed

## Install terminal and configure it
- `sudo pacman -S alacritty`
- `mkdir -p ~/.config/alacritty`
- `curl -LO --output-dir ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-frappe.toml`
- `vim .config/alacritty/alacritty.toml`
- ```
  import = [
    # uncomment the flavour you want below:
    # "~/.config/alacritty/catppuccin-latte.toml"
    "~/.config/alacritty/catppuccin-frappe.toml"
    # "~/.config/alacritty/catppuccin-macchiato.toml"
    # "~/.config/alacritty/catppuccin-mocha.toml"
  ]
  
  [env]
  TERM = "xterm-256color"
  
  [window]
  padding = { x = 5, y = 5 }
  opacity = 0.9
  blur = true
  
  [font]
  size = 10.0
  
  [font.bold]
  family = "JetBrainsMono Nerd Font Mono"
  style = "Bold"
  
  [font.bold_italic]
  family = "JetBrainsMono Nerd Font Mono"
  style = "Bold Italic"
  
  [font.italic]
  family = "JetBrainsMono Nerd Font Mono"
  style = "Italic"
  
  [font.normal]
  family = "JetBrainsMono Nerd Font Mono"
  style = "Regular"
  ```
- TBD ZSH and Starship or alternative
