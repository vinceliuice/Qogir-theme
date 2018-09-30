## Qogir Gtk Theme

Qogir is a flat Design theme for GTK 3, GTK 2 and Gnome-Shell which supports GTK 3 and GTK 2 based desktop environments like Gnome, Unity, Budgie, Cinnamon Pantheon, XFCE, Mate, etc.

based on Arc gtk theme
horst3180 - Arc gtk theme: https://github.com/horst3180/Arc-theme

## Info

### GTK+ 3.20 or later

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

Usage: ./Install [OPTIONS...]

OPTIONS:
|:-----:|:-----:|
| -d, --dest DIR           | Specify theme destination directory (Default: /home/vince/.themes)                 |
| -n, --name NAME          | Specify theme name (Default: Qogir)                                                |
| -c, --color VARIANTS...  | Specify theme color variant(s) [light|dark] (Default: All variants)                |
| -m, --menu VARIANTS...   | Specify theme appmenu button variant(s) [budgie|gnome] (Default: All variants)     |
| -i, --image VARIANTS...  | Install theme with nautilus background image                                       |
| -s, --square VARIANTS... | Install theme with square titlebutton                                              |
| -h, --help               | Show this help                                                                     |

For example:

    ./Install                        (Install all themes)

    ./Install -m budgie              (Install themes for appmenu button on header)

    ./Install -m gnome               (Install themes for appmenu button on panel)

    ./Install -i                     (Install themes with nautilus background imge)

    ./Install -s                     (Install themes with square titlebuttons)

## Screenshots
![1](https://github.com/vinceliuice/Qogir-theme/blob/master/screenshots/screenshot01.png?raw=true)
![2](https://github.com/vinceliuice/Qogir-theme/blob/master/screenshots/screenshot02.png?raw=true)
![3](https://github.com/vinceliuice/Qogir-theme/blob/master/screenshots/screenshot03.png?raw=true)
![4](https://github.com/vinceliuice/Qogir-theme/blob/master/screenshots/screenshot04.png?raw=true)
![5](https://github.com/vinceliuice/Qogir-theme/blob/master/screenshots/screenshot05.png?raw=true)