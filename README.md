## Qogir Gtk Theme

Qogir is a flat Design theme for GTK 3, GTK 2 and Gnome-Shell which supports GTK 3 and GTK 2 based desktop environments like Gnome, Unity, Budgie, Cinnamon Pantheon, XFCE, Mate, etc.

based on Arc gtk theme
horst3180 - Arc gtk theme: https://github.com/horst3180/Arc-theme

![1](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot01.png?raw=true)

## Info

### GTK+ 3.20 or later
- Set windows button on gnome for a better experience.

Gnome ≥ 3.22:

    gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close


### GTK2 engines requirment
- GTK2 engine Murrine 0.98.1.1 or later.
- GTK2 pixbuf engine or the gtk(2)-engines package.

Fedora/RedHat distros:

    dnf install gtk-murrine-engine gtk2-engines

Ubuntu/Mint/Debian distros:

    sudo apt-get install gtk2-engines-murrine gtk2-engines-pixbuf

ArchLinux:

    pacman -S gtk-engine-murrine gtk-engines

Other:
Search for the engines in your distributions repository or install the engines from source.

## Install

Usage:  ./install.sh  [OPTIONS...]

```sh
  -d, --dest DIR          Specify destination directory (Default: /home/vince/.themes)

  -n, --name NAME         Specify theme name (Default: Qogir)

  -t, --theme VARIANT     Specify theme primary color variant(s) [default|manjaro|ubuntu|all] (Default: blue color)

  -c, --color VARIANT     Specify theme color variant(s) [standard|light|dark] (Default: All variants)

  -i, --icon VARIANT      Specify logo icon on nautilus [default|manjaro|ubuntu|fedora|debian|arch|gnome|budgie|popos|gentoo|void|zorin|mxlinux|opensuse] (Default: mountain icon)

  -g, --gdm               Install GDM theme, this option need root user authority! please run this with sudo

  -l, --libadwaita        Install link to gtk4 config for theming libadwaita

  -r, --remove,
  -u, --uninstall         Uninstall/Remove installed themes

  --tweaks                Specify versions for tweaks [image|square|round] (options can mix use)
                          1. image:      Install with a background image on (Nautilus/Nemo)
                          2. square:     Install square window button like Windows 10
                          3. round:      Install rounded window and popup/menu version

  -h, --help              Show help


```

**FOR EXAMPLE:**

Install default themes

```sh
./install.sh
```

Install dark rounded window version and links for libadwaita

```sh
./install.sh --tweaks round -c dark -l
```

Install rounded window version with square window button and nautilus background image

```sh
./install.sh --tweaks image square round
```

Install standard dark gdm theme

```sh
sudo ./install.sh -g -c dark -t default
```

Uninstall gdm theme

```sh
sudo ./install.sh -g -r
```

### On Flatpak

All variants are available via Flathub:

```
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.gtk.Gtk3theme.Qogir{,-dark,-light,-win,-manjaro, ...}
```

### Install on FreeBSD

- Qogir Theme ：`pkg install qogir-gtk-themes`

- Qogir Icon: `pkg install qogir-icon-themes`

### Install on OpenBSD

Let me show you how to install this theme on OpenBSD

```sh
sudo pkg_add bash
sudo ln -s /usr/local/bin/bash /bin/bash
git clone https://github.com/vinceliuice/Qogir-theme
cd Qogir-theme
bash install.sh
```

## Nautilus logos
```sh
./install.sh -i [LOGO NAME...] (Install themes with selected nautilus logo)
```

![logo](https://github.com/vinceliuice/Qogir-theme/blob/images/logos.png?raw=true)

## Firefox theme
[Install Firefox theme](src/firefox)

![firefox-theme](src/firefox/preview.png?raw=true)

### AUR
[AUR](https://aur.archlinux.org/packages/qogir-gtk-theme/)

### Kde theme
[Qogir-kde](https://github.com/vinceliuice/Qogir-kde)

### Icon theme
[Qogir](https://github.com/vinceliuice/Qogir-icon-theme)

## Screenshots
![2](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot02.png?raw=true)
![3](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot03.png?raw=true)
![4](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot04.png?raw=true)
![5](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot05.png?raw=true)
