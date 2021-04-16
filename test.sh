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

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

SRC_DIR=$(cd $(dirname $0) && pwd)

THEME_NAME=Qogir
WIN_VARIANTS=('' '-win')
COLOR_VARIANTS=('' '-light' '-dark')
LOGO_NAME=''

if [[ "$(command -v gnome-shell)" ]]; then
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -2)"
  if [[ "${SHELL_VERSION:-}" == '40.0' ]]; then
    GS_VERSION="new"
  else
    GS_VERSION="old"
  fi
  else
    echo "'gnome-shell' not found, using styles for last gnome-shell version available."
    GS_VERSION="new"
fi

install() {
  local dest=${1}
  local name=${2}
  local win=${3}
  local color=${4}

  [[ ${color} == '-dark' ]] && local ELSE_DARK=${color}
  [[ ${color} == '-light' ]] && local ELSE_LIGHT=${color}

  local THEME_DIR=${dest}/${name}${win}${color}

  [[ -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                           ${THEME_DIR}
  cp -r ${SRC_DIR}/COPYING                                                           ${THEME_DIR}
  cp -r ${SRC_DIR}/AUTHORS                                                           ${THEME_DIR}

  echo "[Desktop Entry]"                                                          >> ${THEME_DIR}/index.theme
  echo "Type=X-GNOME-Metatheme"                                                   >> ${THEME_DIR}/index.theme
  echo "Name=${name}${win}${color}"                                               >> ${THEME_DIR}/index.theme
  echo "Comment=An Clean Gtk+ theme based on Flat Design"                         >> ${THEME_DIR}/index.theme
  echo "Encoding=UTF-8"                                                           >> ${THEME_DIR}/index.theme
  echo ""                                                                         >> ${THEME_DIR}/index.theme
  echo "[X-GNOME-Metatheme]"                                                      >> ${THEME_DIR}/index.theme
  echo "GtkTheme=${name}${win}${color}"                                           >> ${THEME_DIR}/index.theme
  echo "MetacityTheme=${name}${win}${color}"                                      >> ${THEME_DIR}/index.theme
  echo "IconTheme=${name}${ELSE_DARK}"                                            >> ${THEME_DIR}/index.theme
  echo "CursorTheme=Adwaita"                                                      >> ${THEME_DIR}/index.theme
  echo "ButtonLayout=menu:minimize,maximize,close"                                >> ${THEME_DIR}/index.theme

  mkdir -p                                                                           ${THEME_DIR}/gtk-2.0
  cp -r ${SRC_DIR}/src/gtk-2.0/{apps.rc,panel.rc,main.rc,xfce-notify.rc}             ${THEME_DIR}/gtk-2.0
  cp -r ${SRC_DIR}/src/gtk-2.0/assets/assets${ELSE_DARK}                             ${THEME_DIR}/gtk-2.0/assets
  cp -r ${SRC_DIR}/src/gtk-2.0/theme/gtkrc${color}                                   ${THEME_DIR}/gtk-2.0/gtkrc
  cp -r ${SRC_DIR}/src/gtk-2.0/menubar-toolbar${color}.rc                            ${THEME_DIR}/gtk-2.0/menubar-toolbar.rc

  mkdir -p                                                                           ${THEME_DIR}/gtk-3.0
  cp -r ${SRC_DIR}/src/gtk/assets/assets                                             ${THEME_DIR}/gtk-3.0/assets

  if [[ -f ${SRC_DIR}/src/gtk/assets/logos/logo-${logo}.svg ]] ; then
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo-${logo}.svg                           ${THEME_DIR}/gtk-3.0/assets/logo.svg
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo@2-${logo}.svg                         ${THEME_DIR}/gtk-3.0/assets/logo@2.svg
  else
    echo "${logo} icon not supported, default icon will install..."
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo-.svg                                  ${THEME_DIR}/gtk-3.0/assets/logo.svg
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo@2-.svg                                ${THEME_DIR}/gtk-3.0/assets/logo@2.svg
  fi

  cp -r ${SRC_DIR}/src/gtk/assets/assets-common/*                                    ${THEME_DIR}/gtk-3.0/assets
  cp -r ${SRC_DIR}/src/gtk/theme-3.0/gtk${win}${color}.css                           ${THEME_DIR}/gtk-3.0/gtk.css
  [[ ${color} != '-dark' ]] && \
  cp -r ${SRC_DIR}/src/gtk/theme-3.0/gtk${win}-dark.css                              ${THEME_DIR}/gtk-3.0/gtk-dark.css
  cp -r ${SRC_DIR}/src/gtk/assets/thumbnail${ELSE_DARK}.png                          ${THEME_DIR}/gtk-3.0/thumbnail.png

  mkdir -p                                                                           ${THEME_DIR}/gtk-4.0
  cp -r ${SRC_DIR}/src/gtk/assets/assets                                             ${THEME_DIR}/gtk-4.0/assets

  if [[ -f ${SRC_DIR}/src/gtk/assets/logos/logo-${logo}.svg ]] ; then
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo-${logo}.svg                           ${THEME_DIR}/gtk-4.0/assets/logo.svg
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo@2-${logo}.svg                         ${THEME_DIR}/gtk-4.0/assets/logo@2.svg
  else
    echo "${logo} icon not supported, default icon will install..."
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo-.svg                                  ${THEME_DIR}/gtk-4.0/assets/logo.svg
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo@2-.svg                                ${THEME_DIR}/gtk-4.0/assets/logo@2.svg
  fi

  cp -r ${SRC_DIR}/src/gtk/assets/assets-common/*                                    ${THEME_DIR}/gtk-4.0/assets
  cp -r ${SRC_DIR}/src/gtk/theme-4.0/gtk${win}${color}.css                           ${THEME_DIR}/gtk-4.0/gtk.css
  [[ ${color} != '-dark' ]] && \
  cp -r ${SRC_DIR}/src/gtk/theme-4.0/gtk${win}-dark.css                              ${THEME_DIR}/gtk-4.0/gtk-dark.css
  cp -r ${SRC_DIR}/src/gtk/assets/thumbnail${ELSE_DARK}.png                          ${THEME_DIR}/gtk-4.0/thumbnail.png

  mkdir -p                                                                           ${THEME_DIR}/gnome-shell
  cp -r ${SRC_DIR}/src/gnome-shell/common-assets                                     ${THEME_DIR}/gnome-shell/assets
  cp -r ${SRC_DIR}/src/gnome-shell/assets/*.svg                                      ${THEME_DIR}/gnome-shell/assets
  cp -r ${SRC_DIR}/src/gnome-shell/assets/assets${ELSE_DARK}/*.svg                   ${THEME_DIR}/gnome-shell/assets
  cp -r ${SRC_DIR}/src/gnome-shell/background.jpeg                                   ${THEME_DIR}/gnome-shell/background.jpeg

  if [[ -f ${SRC_DIR}/src/gnome-shell/logos/logo-${logo}.svg ]] ; then
    cp -r ${SRC_DIR}/src/gnome-shell/logos/logo-${logo}.svg                          ${THEME_DIR}/gnome-shell/assets/activities.svg
  else
    echo "${logo} icon not supported, Qogir icon will install..."
    cp -r ${SRC_DIR}/src/gnome-shell/logos/logo-qogir.svg                            ${THEME_DIR}/gnome-shell/assets/activities.svg
  fi

  cp -r ${SRC_DIR}/src/gnome-shell/icons                                             ${THEME_DIR}/gnome-shell
  cp -r ${SRC_DIR}/src/gnome-shell/pad-osd.css                                       ${THEME_DIR}/gnome-shell

  if [[ "${GS_VERSION:-}" == 'new' ]]; then
    cp -r ${SRC_DIR}/src/gnome-shell/theme-40-0/gnome-shell${color}.css              ${THEME_DIR}/gnome-shell/gnome-shell.css
  else
    cp -r ${SRC_DIR}/src/gnome-shell/theme-3-32/gnome-shell${color}.css              ${THEME_DIR}/gnome-shell/gnome-shell.css
  fi

  cd ${THEME_DIR}/gnome-shell
  ln -sf assets/no-events.svg no-events.svg
  ln -sf assets/process-working.svg process-working.svg
  ln -sf assets/no-notifications.svg no-notifications.svg

  mkdir -p                                                                           ${THEME_DIR}/cinnamon
  cp -r ${SRC_DIR}/src/cinnamon/assets/common-assets                                 ${THEME_DIR}/cinnamon
  cp -r ${SRC_DIR}/src/cinnamon/assets/assets${ELSE_DARK}                            ${THEME_DIR}/cinnamon/assets
  cp -r ${SRC_DIR}/src/cinnamon/theme/cinnamon${ELSE_DARK}.css                       ${THEME_DIR}/cinnamon/cinnamon.css
  cp -r ${SRC_DIR}/src/cinnamon/thumbnail${ELSE_DARK}.png                            ${THEME_DIR}/cinnamon/thumbnail.png

  mkdir -p                                                                           ${THEME_DIR}/metacity-1
  cp -r ${SRC_DIR}/src/metacity-1/assets${ELSE_LIGHT}${win}/*.png                    ${THEME_DIR}/metacity-1
  cp -r ${SRC_DIR}/src/metacity-1/metacity-theme-3${win}.xml                         ${THEME_DIR}/metacity-1/metacity-theme-3.xml
  cp -r ${SRC_DIR}/src/metacity-1/metacity-theme-1${ELSE_LIGHT}${win}.xml            ${THEME_DIR}/metacity-1/metacity-theme-1.xml
  cp -r ${SRC_DIR}/src/metacity-1/thumbnail${ELSE_LIGHT}.png                         ${THEME_DIR}/metacity-1/thumbnail.png
  cd ${THEME_DIR}/metacity-1
  ln -s metacity-theme-1.xml metacity-theme-2.xml

  mkdir -p                                                                           ${THEME_DIR}/xfwm4
  cp -r ${SRC_DIR}/src/xfwm4/themerc${win}${ELSE_LIGHT}                              ${THEME_DIR}/xfwm4/themerc
  cp -r ${SRC_DIR}/src/xfwm4/assets${win}${ELSE_LIGHT}/*.png                         ${THEME_DIR}/xfwm4

  cp -r ${SRC_DIR}/src/plank                                                         ${THEME_DIR}
  cp -r ${SRC_DIR}/src/unity                                                         ${THEME_DIR}
}

# check command avalibility
function has_command() {
  command -v $1 > /dev/null
}

install_theme() {
    for win in "${wins[@]-${WIN_VARIANTS[@]}}"; do
      for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
          install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${win}" "${color}"
      done
    done
}

for win in "${_WIN_VARIANTS[@]}"; do
  for color in "${_COLOR_VARIANTS[@]}"; do
    sassc $SASSC_OPT src/gtk/theme-3.0/gtk${win}${color}.{scss,css}
    echo "==> Generating the gtk-4.0${win}${color}.css..."
    sassc $SASSC_OPT src/gtk/theme-4.0/gtk${win}${color}.{scss,css}
    echo "==> Generating the gtk-4.0${win}${color}.css..."
  done
done


for color in "${_COLOR_VARIANTS[@]}"; do
  sassc $SASSC_OPT src/gnome-shell/theme-3-32/gnome-shell${color}.{scss,css}
  echo "==> Generating the gnome-shell-3-32${color}.css..."
  sassc $SASSC_OPT src/gnome-shell/theme-40-0/gnome-shell${color}.{scss,css}
  echo "==> Generating the gnome-shell-40-0${color}.css..."
  sassc $SASSC_OPT src/cinnamon/theme/cinnamon${color}.{scss,css}
  echo "==> Generating the cinnamon${color}.css..."
done

install_theme

