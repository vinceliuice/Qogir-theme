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

Usage:  ./Install  [OPTIONS...]

|  OPTIONS:    | |
|:-------------|:-------------|
| -d, --dest   | destination directory (Default: $HOME/.themes) |
| -n, --name   | name (Default: Qogir) |
| -c, --color  | color variant(s) (standard/light/dark) |
| -i, --image  | Install theme with nautilus background image |
| -w, --win    | titlebutton variant(s) (standard/square) |
| -h, --help   | Show this help |

**FOR EXAMPLE:**
```sh
./Install
```
(Install all themes)
```sh
./Install -i
```
(Install themes with nautilus background imge)

## Screenshots
![1](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot01.png?raw=true)
![2](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot02.png?raw=true)
![3](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot03.png?raw=true)
![4](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot04.png?raw=true)
![5](https://github.com/vinceliuice/Qogir-theme/blob/images/screenshots/screenshot05.png?raw=true)
