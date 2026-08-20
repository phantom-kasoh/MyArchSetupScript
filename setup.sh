echo "installing shell, prompt, terminal emulator, file editor, file manager, font, git, curl"
sudo pacman -S --needed zsh starship ghostty neovim yazi ttf-firacode-nerd git curl

echo "installing shell QoL"
sudo pacman -S --needed zsh-completions zsh-autosuggestions zsh-syntax-highlighting

echo "enabling multilib repo"
if ! grep -q "^\[multilib\]" /ect/pacman.conf; then
	sudo sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
	echo "multilib enabled"
else
	echo "multilib is already enabled"
fi

echo "running sudo pacman -Syyu"
sudo pacman -Syyu

echo "installing wayland"
sudo pacman -S --needed wayland qt5-wayland qt6-wayland

echo "installing hyprland stuff"
sudo pacman -S --needed hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk hyprpolkitagent mako wofi pavucontrol

echo "installing pipewire"
sudo pacman -S --needed pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack

echo "installing GPU drivers"
sudo pacman -S --needed mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings

echo "installing & enable network"
sudo pacman -S --needed iwd systemd-resolvconf
sudo systemctl enable --now systemd-networkd systemd-resolved

echo "installing hyprland ecosystem tools"
sudo pacman -S --needed hypridle hyprlock hyprpaper hyprshot

echo "installing Clipboard & screenshots"
sudo pacman -S --needed wl-clipboard grim slurp

echo "installing backup fonts"
sudo pacman -S --needed noto-fonts noto-fonts-emoji

echo "installing waybar"
sudo pacman -S --needed waybar

echo "installing man"
sudo pacman -S --needed man-db man-pages

echo "installing system utils"
sudo pacman -S --needed base-devel xdg-user-dirs xdg-utils wget openssh

echo "installing archive tools"
sudo pacman -S --needed tar 7zip unrar

echo "installing system info & monitoring"
sudo pacman -S --needed btop fastfetch texinfo

echo "creating fastfetch default config"
fastfetch --gen-config

echo "better cli tools"
sudo pacman -S --needed bat eza fd ripgrep fzf rsync which

echo "installing rust"
sudo pacman -S rustup
rustup default stable

if ! command -v paru >/dev/null 2>&1; then
	echo "installing paru"
	git clone https://aur.archlinux.org/paru.git
	cd paru
	makepkg -si
	cd ..
	sudo rm -r paru
else
	echo "Paru is installed"
fi

echo "installing mirrors & pacman helpers"
sudo pacman -S --needed reflector pacman-contrib

echo "installing low level dev stuff"
sudo pacman -S --needed nasm binutils gdb gcc make strace ltrace xxd

echo "installing wine"
sudo pacman -S --needed wine-staging winetricks
paru -S bottles

echo "installing programming languages"
sudo pacman -S --needed python python-pip uv gcc clang go nodejs npm lua

echo "installing ad-blocker"
sudo pacman -S --needed hblock

echo "installing boxes"
sudo pacman -S --needed gnome-boxes

echo "----------------------------------------------------------------------------------"

echo "Reboot to apply changes most changes in this section"

echo "setting Zsh as default shell"
chsh -s /usr/bin/zsh
echo "making Zsh config file in ~/.config/zsh"
mkdir -p ~/.config/zsh
cat > ~/.zshenv << 'EOF'
export ZDOTDIR="$HOME/.config/zsh"
EOF
echo "making a basic .zshrc"
cat > ~/.config/zsh/.zshrc << 'EOF'
# Aliases
alias cat='bat'
alias ls='eza'
alias ll='eza -l --git'
alias la='eza -la --git'
alias tree='eza --tree'
alias vim='nvim'

# run FastFetch in interactive terminals (ghostty)
if [[ -o interactive ]]; then
	fastfetch -c paleofetch
fi

# Starship
eval "$(starship init zsh)"
EOF

echo "making ~/.config/zsh/.zprofile"
cat > ~/.config/zsh/.zprofile << 'EOF'
# Start Hyprland automatically on TTY1
if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
	exec Hyprland
fi
EOF

echo "making basic starship conifg"
starship preset nerd-font-symbols -o ~/.config/starship.toml

echo "setting the font"
echo "making the ~/.config/ghostty"
mkdir -p ~/.config/ghostty
echo "writing the config file"
cat > ~/.config/ghostty/config << 'EOF'
# Font
font-family = FiraCode Nerd Font
font-size = 12

# Window
window-padding-x = 10
window-padding-y = 8
window-decoration = true

# Cursor
cursor-style = bar
cursor-style-blink = true

# Clipboard
copy-on-select = true

# Keybinds for copy/paste
keybind = ctrl+shift+c=copy_to_clipboard
keybind = ctrl+shift+v=paste_from_clipboard

# Other
confirm-close-surface = false
shell-integration = zsh

# Transparency
background-opacity = 0.85
background-blur = true
EOF
echo "Font has been set to FiraCode Nerd and ghostty base config has been made"

echo "setting up hyprland"
echo "making hyprland config dir in ~/.config/hypr"
mkdir -p ~/.config/hypr
echo "making minimal workihng config"
cat > ~/.config/hypr/hyprland.conf << 'EOF'
# Minimal Hyprland config

monitor=,preferred,auto,1

exec-once = waybar
exec-once = mako
exec-once = hyprpaper

input {
	kb_layout = us
	follow_mouse = 1
}

general {
	gaps_in = 5
	gaps_out = 10
	border_size = 2
	col.active_border = rgba(cba6f7ee)
	col.inactive_border = rgba(595959aa)
}

decoration {
	rounding = 0
	blur {
		enabled = true
		size = 6
		passes = 2
	}
}

animations {
	enabled = true
}

dwindle {
	preserve_split = true
}

bind = SUPER, Return, exec, ghostty
bind = SUPER, Q, killactive
bind = SUPER, M, exit
bind = SUPER, E, exec, yazi
bind = SUPER, V, togglefloating
bing = SUPER, F, fullscreen
bing = SUPER, Space, exec, wofi --show drun

bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5

bind = SUPER SHIFT, 1, movetoworkspace, 1
bind = SUPER SHIFT, 2, movetoworkspace, 2
bind = SUPER SHIFT, 3, movetoworkspace, 3
bind = SUPER SHIFT, 4, movetoworkspace, 4
bind = SUPER SHIFT, 5, movetoworkspace, 5
EOF

if ! grep -q "^\[blackarch\]" /etc/pacman.conf; then
	echo "setting up BlackArch Repo"
	curl -O https://blackarch.org/strap.sh
	chmod +x strap.sh
	sudo ./strap.sh
	rm strap.sh
else
	echo "You already have the Black arch repo"
fi

echo "updating Databases and packages"
sudo reflector \
	--country 'United States' \
	--latest 20 \
	--protocol https \
	--sort rate \
	--save /etc/pacman.d/mirrorlist
sudo pacman -Syyu

echo "installing blackman"
paru -S blackman

echo "setting up hblock (ad blocker)"
sudo hblock
sudo systemctl enable --now hblock.timer
systemctl status hblock.timer

