## Qogir Gtk Theme

Qogir is a flat Design theme for GTK 3, GTK 2 and Gnome-Shell which supports GTK 3 and GTK 2 based desktop environments like Gnome, Unity, Budgie, Cinnamon Pantheon, XFCE, Mate, etc.

based on Arc gtk theme
horst3180 - Arc gtk theme: https://github.com/horst3180/Arc-theme

## Info

### GTK+ 3.20 or later
- Set windows button on gnome for a better experience.

Gnome ≥ 3.22:

    gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close


### GTK2 engines requirment
- GTK2 engine Murrine 0.98.1.1 or later.
- GTK2 pixbuf engine or the gtk(2)-engines package.

Fedora/RedHat distros:

    yum install gtk-murrine-engine gtk2-engines

Ubuntu/Mint/Debian distros:

    sudo apt-get install gtk2-engines-murrine gtk2-engines-pixbuf

ArchLinux:

    pacman -S gtk-engine-murrine gtk-engines

Other:
Search for the engines in your distributions repository or install the engines from source.

## Install

Usage:  ./install.sh  [OPTIONS...]

|  OPTIONS:    | |
|:-------------|:-------------|
| -d, --dest   | destination directory (Default: $HOME/.themes) |
| -n, --name   | name (Default: Qogir) |
| -t, --theme  | theme primary color variant(s) (standard/manjaro/ubuntu) |
| -c, --color  | color variant(s) (standard/light/dark) |
| -i, --image  | Install theme with nautilus background image |
| -w, --win    | titlebutton variant(s) (standard/square) |
| -g, --gdm    | Install GDM theme, you should run this with sudo!|
| -r, --revert | revert GDM theme, you should run this with sudo!|
| -h, --help   | Show this help |

**FOR EXAMPLE:**
```sh
./install.sh  (Install all themes)
```

```sh
./install.sh -i  (Install themes with nautilus background image)
```

```sh
sudo ./install.sh -g -c dark -t standard  (Install standard dark gdm theme)
```

## Firefox issues

### Fix entries issues of dark version on Firefox

Use "light theme" for webs on Firefox.

1. Go to `about:config`,

2. create a pref called `widget.content.gtk-theme-override` of type String,

3. and give it a value of `Qogir-light` (or `Qogir-win-light` ). This will fix it.

### Fix win titlebutton issues on Firefox

add the `src/other/firefox/userChrome.css` into `~/.mozilla/firefox/{your_profile}/chrome/`

### Flatpak

All variants are available via Flathub:

```
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.gtk.Gtk3theme.Qogir{,-dark,-light,-win,-manjaro, ...}
```

### Kde theme
[Qogir-kde](https://github.com/vinceliuice/Qogir-kde)

### Icon theme
[Qogir](https://github.com/vinceliuice/Qogir-icon-theme)

## Screenshots
![1](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot01.png?raw=true)
![2](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot02.png?raw=true)
![3](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot03.png?raw=true)
![4](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot04.png?raw=true)
![5](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot05.png?raw=true)
