#!/bin/bash

if [ ! "$(which sassc 2> /dev/null)" ]; then
   echo sassc needs to be installed to generate the css.
   exit 1
fi

SASSC_OPT="-M -t expanded"

SRC_DIR=$(cd $(dirname $0) && pwd)

_COLOR_VARIANTS=('' '-Light' '-Dark')

if [ ! -z "${COLOR_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _COLOR_VARIANTS <<< "${COLOR_VARIANTS:-}"
fi

_COLOR_D_VARIANTS=('' '-Dark')

if [ ! -z "${COLOR_D_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _COLOR_D_VARIANTS <<< "${COLOR_D_VARIANTS:-}"
fi

cp -rf ${SRC_DIR}/src/_sass/_tweaks.scss ${SRC_DIR}/src/_sass/_tweaks-temp.scss

for color in "${_COLOR_VARIANTS[@]}"; do
  sassc $SASSC_OPT src/gtk/theme-3.0/gtk${color}.{scss,css}
  echo "==> Generating the gtk-3.0${color}.css..."
  sassc $SASSC_OPT src/gtk/theme-4.0/gtk${color}.{scss,css}
  echo "==> Generating the gtk-4.0${color}.css..."
done

for color in "${_COLOR_D_VARIANTS[@]}"; do
  sassc $SASSC_OPT src/gnome-shell/theme-3-32/gnome-shell${color}.{scss,css}
  echo "==> Generating the gnome-shell-3-32${color}.css..."
  sassc $SASSC_OPT src/gnome-shell/theme-40-0/gnome-shell${color}.{scss,css}
  echo "==> Generating the gnome-shell-40-0${color}.css..."
  sassc $SASSC_OPT src/gnome-shell/theme-42-0/gnome-shell${color}.{scss,css}
  echo "==> Generating the gnome-shell-42-0${color}.css..."
  sassc $SASSC_OPT src/gnome-shell/theme-44-0/gnome-shell${color}.{scss,css}
  echo "==> Generating the gnome-shell-44-0${color}.css..."
  sassc $SASSC_OPT src/cinnamon/cinnamon${color}.{scss,css}
  echo "==> Generating the cinnamon${color}.css..."
done

