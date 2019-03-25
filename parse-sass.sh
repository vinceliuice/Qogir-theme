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

for win in "${_WIN_VARIANTS[@]}"; do
  for color in "${_COLOR_VARIANTS[@]}"; do
    sassc $SASSC_OPT src/gtk-3.0/gtk${win}${color}.{scss,css}
    echo "==> Generating the gtk${win}${color}.css..."
  done
done

for color in "${_COLOR_VARIANTS[@]}"; do
  sassc $SASSC_OPT src/gnome-shell/gnome-shell${color}.{scss,css}
  echo "==> Generating the gnome-shell${color}.css..."
  sassc $SASSC_OPT src/cinnamon/cinnamon${color}.{scss,css}
  echo "==> Generating the cinnamon${color}.css..."
done

