#!/bin/bash

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
COLOR_VARIANTS=('' '-dark' '-light')
CIRCLE_VARIANTS=('' '-win')

install() {
  local dest=${1}
  local name=${2}
  local color=${3}
  local circle=${4}

  [[ ${color} == '-dark' ]] && local ELSE_DARK=${color}
  [[ ${color} == '-light' ]] && local ELSE_LIGHT=${color}

  local THEME_DIR=${DEST_DIR}/${name}${circle}${color}

  [[ -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                           ${THEME_DIR}
  cp -ur ${SRC_DIR}/COPYING                                                          ${THEME_DIR}
  cp -ur ${SRC_DIR}/AUTHORS                                                          ${THEME_DIR}

  echo "[Desktop Entry]" >> ${THEME_DIR}/index.theme
  echo "Type=X-GNOME-Metatheme" >> ${THEME_DIR}/index.theme
  echo "Name=Qogir${circle}${color}" >> ${THEME_DIR}/index.theme
  echo "Comment=An Clean Gtk+ theme based on Flat Design" >> ${THEME_DIR}/index.theme
  echo "Encoding=UTF-8" >> ${THEME_DIR}/index.theme
  echo "" >> ${THEME_DIR}/index.theme
  echo "[X-GNOME-Metatheme]" >> ${THEME_DIR}/index.theme
  echo "GtkTheme=Qogir${circle}${color}" >> ${THEME_DIR}/index.theme
  echo "MetacityTheme=Qogir${circle}${color}" >> ${THEME_DIR}/index.theme
  echo "IconTheme=Adwaita" >> ${THEME_DIR}/index.theme
  echo "CursorTheme=Adwaita" >> ${THEME_DIR}/index.theme
  echo "ButtonLayout=menu:minimize,maximize,close" >> ${THEME_DIR}/index.theme

  mkdir -p                                                                           ${THEME_DIR}/gtk-2.0
  cp -ur ${SRC_DIR}/src/gtk-2.0/{apps.rc,panel.rc,main.rc,xfce-notify.rc}            ${THEME_DIR}/gtk-2.0
  cp -ur ${SRC_DIR}/src/gtk-2.0/assets${ELSE_DARK}                                   ${THEME_DIR}/gtk-2.0/assets
  cp -ur ${SRC_DIR}/src/gtk-2.0/gtkrc${color}                                        ${THEME_DIR}/gtk-2.0/gtkrc
  cp -ur ${SRC_DIR}/src/gtk-2.0/menubar-toolbar${color}.rc                           ${THEME_DIR}/gtk-2.0/menubar-toolbar.rc

  mkdir -p                                                                           ${THEME_DIR}/gtk-3.0
  cp -ur ${SRC_DIR}/src/gtk-3.0/assets                                               ${THEME_DIR}/gtk-3.0
  cp -ur ${SRC_DIR}/src/gtk-3.0/gtk${circle}${color}.css                             ${THEME_DIR}/gtk-3.0/gtk.css
  [[ ${color} != '-dark' ]] && \
  cp -ur ${SRC_DIR}/src/gtk-3.0/gtk${circle}-dark.css                                ${THEME_DIR}/gtk-3.0/gtk-dark.css

  mkdir -p                                                                           ${THEME_DIR}/gnome-shell
  cp -ur ${SRC_DIR}/src/gnome-shell/common-assets                                    ${THEME_DIR}/gnome-shell
  cp -ur ${SRC_DIR}/src/gnome-shell/assets${ELSE_DARK}                               ${THEME_DIR}/gnome-shell/assets
  cp -ur ${SRC_DIR}/src/gnome-shell/gnome-shell${color}.css                          ${THEME_DIR}/gnome-shell/gnome-shell.css

  mkdir -p                                                                           ${THEME_DIR}/metacity-1
  cp -ur ${SRC_DIR}/src/metacity-1/*.svg                                             ${THEME_DIR}/metacity-1
  cp -ur ${SRC_DIR}/src/metacity-1/metacity-theme-1${ELSE_DARK}.xml                  ${THEME_DIR}/metacity-1/metacity-theme-1.xml
  cd ${THEME_DIR}/metacity-1
  ln -s metacity-theme-1.xml metacity-theme-2.xml
  ln -s metacity-theme-1.xml metacity-theme-3.xml

  mkdir -p                                                                           ${THEME_DIR}/xfwm4
  cp -ur ${SRC_DIR}/src/xfwm4/themerc${ELSE_LIGHT}                                   ${THEME_DIR}/xfwm4/themerc
  cp -ur ${SRC_DIR}/src/xfwm4/assets${ELSE_LIGHT}/*.png                              ${THEME_DIR}/xfwm4

}

for color in "${circles[@]:-${CIRCLE_VARIANTS[@]}}"; do
  for circle in "${colors[@]:-${COLOR_VARIANTS[@]}}"; do
    install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${circle}" "${color}"
  done
done

echo
echo Done.
