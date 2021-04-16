#! /bin/bash

if [ ! "$(which sassc 2> /dev/null)" ]; then
   echo sassc needs to be installed to generate the css.
   exit 1
fi

SASSC_OPT="-M -t expanded"

_COLOR_VARIANTS=('' '-light' '-dark')
if [ ! -z "${COLOR_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _COLOR_VARIANTS <<< "${COLOR_VARIANTS:-}"
fi

_WIN_VARIANTS=('' '-win')
if [ ! -z "${WIN_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _WIN_VARIANTS <<< "${WIN_VARIANTS:-}"
fi

_THEME_VARIANTS=('' '-manjaro' '-ubuntu')
if [ ! -z "${THEME_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _THEME_VARIANTS <<< "${THEME_VARIANTS:-}"
fi

for theme in "${_THEME_VARIANTS[@]}"; do
for win in "${_WIN_VARIANTS[@]}"; do
  for color in "${_COLOR_VARIANTS[@]}"; do
    sassc $SASSC_OPT src/gtk/theme${theme}-3.0/gtk${win}${color}.{scss,css}
    echo "==> Generating the gtk-4.0${theme}${win}${color}.css..."
    sassc $SASSC_OPT src/gtk/theme${theme}-4.0/gtk${win}${color}.{scss,css}
    echo "==> Generating the gtk-4.0${theme}${win}${color}.css..."
  done
done
done

for theme in "${_THEME_VARIANTS[@]}"; do
  for color in "${_COLOR_VARIANTS[@]}"; do
  sassc $SASSC_OPT src/gnome-shell/theme${theme}-3-32/gnome-shell${color}.{scss,css}
  echo "==> Generating the gnome-shell${theme}-3-32${color}.css..."
  sassc $SASSC_OPT src/gnome-shell/theme${theme}-40-0/gnome-shell${color}.{scss,css}
  echo "==> Generating the gnome-shell${theme}-40-0${color}.css..."
  sassc $SASSC_OPT src/cinnamon/theme${theme}/cinnamon${color}.{scss,css}
  echo "==> Generating the cinnamon${theme}${color}.css..."
  done
done

