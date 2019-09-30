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
THEME_VARIANTS=('' '-manjaro' '-ubuntu')
WIN_VARIANTS=('' '-win')
COLOR_VARIANTS=('' '-light' '-dark')

XML_HEADER='<?xml version="1.0" encoding="UTF-8"?>
<gresources>
  <gresource prefix="/org/gnome/shell/theme">'
XML_FOOT='  </gresource>
</gresources>'


usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-d, --dest DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n, --name NAME" "Specify theme name (Default: ${THEME_NAME})"
  printf "  %-25s%s\n" "-w, --win VARIANTS..." "Specify titlebutton variant(s) [standard|square] (Default: All variants)"
  printf "  %-25s%s\n" "-c, --color VARIANTS..." "Specify theme color variant(s) [standard|light|dark] (Default: All variants)"
  printf "  %-25s%s\n" "-i, --image VARIANTS..." "Install theme with nautilus background image"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
}

install() {
  local dest=${1}
  local name=${2}
  local theme=${3}
  local win=${4}
  local color=${5}

  [[ ${color} == '-dark' ]] && local ELSE_DARK=${color}
  [[ ${color} == '-light' ]] && local ELSE_LIGHT=${color}

  local THEME_DIR=${dest}/${name}${theme}${win}${color}

  [[ -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                           ${THEME_DIR}
  cp -ur ${SRC_DIR}/COPYING                                                          ${THEME_DIR}
  cp -ur ${SRC_DIR}/AUTHORS                                                          ${THEME_DIR}

  echo "[Desktop Entry]"                                                          >> ${THEME_DIR}/index.theme
  echo "Type=X-GNOME-Metatheme"                                                   >> ${THEME_DIR}/index.theme
  echo "Name=${name}${theme}${win}${color}"                                       >> ${THEME_DIR}/index.theme
  echo "Comment=An Clean Gtk+ theme based on Flat Design"                         >> ${THEME_DIR}/index.theme
  echo "Encoding=UTF-8"                                                           >> ${THEME_DIR}/index.theme
  echo ""                                                                         >> ${THEME_DIR}/index.theme
  echo "[X-GNOME-Metatheme]"                                                      >> ${THEME_DIR}/index.theme
  echo "GtkTheme=${name}${theme}${win}${color}"                                   >> ${THEME_DIR}/index.theme
  echo "MetacityTheme=${name}${theme}${win}${color}"                              >> ${THEME_DIR}/index.theme
  echo "IconTheme=${name}${theme}${ELSE_DARK}"                                    >> ${THEME_DIR}/index.theme
  echo "CursorTheme=Adwaita"                                                      >> ${THEME_DIR}/index.theme
  echo "ButtonLayout=menu:minimize,maximize,close"                                >> ${THEME_DIR}/index.theme

  mkdir -p                                                                           ${THEME_DIR}/gtk-2.0
  cp -ur ${SRC_DIR}/src/gtk-2.0/{apps.rc,panel.rc,main.rc,xfce-notify.rc}            ${THEME_DIR}/gtk-2.0
  cp -ur ${SRC_DIR}/src/gtk-2.0/assets/assets${theme}${ELSE_DARK}                    ${THEME_DIR}/gtk-2.0/assets
  cp -ur ${SRC_DIR}/src/gtk-2.0/theme${theme}/gtkrc${color}                          ${THEME_DIR}/gtk-2.0/gtkrc
  cp -ur ${SRC_DIR}/src/gtk-2.0/menubar-toolbar${color}.rc                           ${THEME_DIR}/gtk-2.0/menubar-toolbar.rc

  mkdir -p                                                                           ${THEME_DIR}/gtk-3.0
  cp -ur ${SRC_DIR}/src/gtk-3.0/assets/assets${theme}                                ${THEME_DIR}/gtk-3.0/assets
  cp -ur ${SRC_DIR}/src/gtk-3.0/assets/assets-common/*.png                           ${THEME_DIR}/gtk-3.0/assets
  cp -ur ${SRC_DIR}/src/gtk-3.0/theme${theme}/gtk${win}${color}.css                  ${THEME_DIR}/gtk-3.0/gtk.css
  [[ ${color} != '-dark' ]] && \
  cp -ur ${SRC_DIR}/src/gtk-3.0/theme${theme}/gtk${win}-dark.css                     ${THEME_DIR}/gtk-3.0/gtk-dark.css
  cp -ur ${SRC_DIR}/src/gtk-3.0/assets/thumbnail${theme}${ELSE_DARK}.png             ${THEME_DIR}/gtk-3.0/thumbnail.png

  mkdir -p                                                                           ${THEME_DIR}/gnome-shell
  cp -ur ${SRC_DIR}/src/gnome-shell/assets${theme}/common-assets                     ${THEME_DIR}/gnome-shell
  cp -ur ${SRC_DIR}/src/gnome-shell/assets${theme}/assets${ELSE_DARK}                ${THEME_DIR}/gnome-shell/assets
  cp -ur ${SRC_DIR}/src/gnome-shell/theme${theme}/gnome-shell${color}.css            ${THEME_DIR}/gnome-shell/gnome-shell.css

  # Generate and compile gresource for gnome-shell
  current_dir=$(pwd)
  cd "${THEME_DIR}/gnome-shell/"
  echo -e "${XML_HEADER}" > gnome-shell-theme.gresource.xml
  find . -type f | sed -e 's/\.\//    <file>/' -e 's/$/<\/file>/' >> gnome-shell-theme.gresource.xml
  echo -e "${XML_FOOT}" >> gnome-shell-theme.gresource.xml
  # compile
  if [ -x $(which glib-compile-resources) ]; then
    glib-compile-resources gnome-shell-theme.gresource.xml
  else
    echo "glib-compile-resources is not installed. Not compiling gnome-shell-theme.gresource.xml"
  fi
  cd "${current_dir}"

  mkdir -p                                                                           ${THEME_DIR}/cinnamon
  cp -ur ${SRC_DIR}/src/cinnamon/assets${theme}/common-assets                        ${THEME_DIR}/cinnamon
  cp -ur ${SRC_DIR}/src/cinnamon/assets${theme}/assets${ELSE_DARK}                   ${THEME_DIR}/cinnamon/assets
  cp -ur ${SRC_DIR}/src/cinnamon/theme${theme}/cinnamon${ELSE_DARK}.css              ${THEME_DIR}/cinnamon/cinnamon.css
  cp -ur ${SRC_DIR}/src/cinnamon/thumbnail${theme}${ELSE_DARK}.png                   ${THEME_DIR}/cinnamon/thumbnail.png

  mkdir -p                                                                           ${THEME_DIR}/metacity-1
  cp -ur ${SRC_DIR}/src/metacity-1/assets${ELSE_LIGHT}${win}/*.png                   ${THEME_DIR}/metacity-1
  cp -ur ${SRC_DIR}/src/metacity-1/metacity-theme-3${win}.xml                        ${THEME_DIR}/metacity-1/metacity-theme-3.xml
  cp -ur ${SRC_DIR}/src/metacity-1/metacity-theme-1${ELSE_LIGHT}${win}.xml           ${THEME_DIR}/metacity-1/metacity-theme-1.xml
  cp -ur ${SRC_DIR}/src/metacity-1/thumbnail${ELSE_LIGHT}.png                        ${THEME_DIR}/metacity-1/thumbnail.png
  cd ${THEME_DIR}/metacity-1
  ln -s metacity-theme-1.xml metacity-theme-2.xml

  mkdir -p                                                                           ${THEME_DIR}/xfwm4
  cp -ur ${SRC_DIR}/src/xfwm4/themerc${win}${ELSE_LIGHT}                             ${THEME_DIR}/xfwm4/themerc
  cp -ur ${SRC_DIR}/src/xfwm4/assets${win}${ELSE_LIGHT}/*.png                        ${THEME_DIR}/xfwm4

  cp -ur ${SRC_DIR}/src/plank                                                        ${THEME_DIR}
  cp -ur ${SRC_DIR}/src/unity                                                        ${THEME_DIR}
}

NBG_N="background-image: none;"
NBG_I="@extend %nautilus_backimage;"

# check command avalibility
function has_command() {
  command -v $1 > /dev/null
}

install_package() {
  if [ ! "$(which sassc 2> /dev/null)" ]; then
    echo "\n sassc needs to be installed to generate the css."

    if has_command zypper; then

      read -p "[ trusted ] specify the root password : " -t 20 -s
      [[ -n "$REPLY" ]] && {
        echo "\n running: sudo zypper in sassc "
        sudo -S <<< $REPLY zypper in sassc
      }|| {
        echo  "\n Operation canceled  Bye"
        exit 1
      }

      elif has_command apt; then

      read -p "[ trusted ] specify the root password : " -t 20 -s
      [[ -n "$REPLY" ]] && {
        echo "\n running: sudo apt install sassc "
        sudo -S <<< $REPLY apt install sassc
      }|| {
        echo  "\n Operation canceled  Bye"
        exit 1
      }

      elif has_command dnf; then

      read -p "[ trusted ] specify the root password : " -t 20 -s
      [[ -n "$REPLY" ]] && {
        echo "\n running: sudo dnf install sassc "
        sudo -S <<< $REPLY dnf install sassc
      }|| {
        echo  "\n Operation canceled  Bye"
        exit 1
      }

      elif has_command yum; then

      read -p "[ trusted ] specify the root password : " -t 20 -s
      [[ -n "$REPLY" ]] && {
        echo "\n running: sudo yum install sassc "
        sudo -S <<< $REPLY yum install sassc
      }|| {
        echo  "\n Operation canceled  Bye"
        exit 1
      }

      elif has_command pacman; then

      read -p "[ trusted ] specify the root password : " -t 20 -s
      [[ -n "$REPLY" ]] && {
        echo "\n running: sudo pacman -S --noconfirm sassc "
        sudo -S <<< $REPLY pacman -S --noconfirm sassc
      }|| {
        echo  "\n Operation canceled  Bye"
        exit 1
      }

    fi
  fi
}

parse_sass() {
  cd ${SRC_DIR} && ./parse-sass.sh
}

install_theme() {
  for theme in "${themes[@]:-${THEME_VARIANTS[@]}}"; do
    for win in "${wins[@]:-${WIN_VARIANTS[@]}}"; do
      for color in "${colors[@]:-${COLOR_VARIANTS[@]}}"; do
        install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${theme}" "${win}" "${color}"
      done
    done
  done
}

install_img() {
  cd ${SRC_DIR}/src/_sass/gtk/apps
  cp -an _gnome.scss _gnome.scss.bak
  sed -i "s/$NBG_N/$NBG_I/g" _gnome.scss
  echo -e "Specify theme with nautilus background image ..."
}

restore_img() {
  cd ${SRC_DIR}/src/_sass/gtk/apps
  [[ -d _gnome.scss.bak ]] && rm -rf _gnome.scss
  mv _gnome.scss.bak _gnome.scss
  echo -e "Restore scss files ..."
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo "ERROR: Destination directory does not exist."
        exit 1
      fi
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -i|--image)
      image='true'
      shift
      ;;
    -w|--win)
      shift
      for win in "${@}"; do
        case "${win}" in
          standard)
            wins+=("${WIN_VARIANTS[0]}")
            shift 1
            ;;
          square)
            wins+=("${WIN_VARIANTS[1]}")
            shift 1
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -c|--color)
      shift
      for color in "${@}"; do
        case "${color}" in
          standard)
            colors+=("${COLOR_VARIANTS[0]}")
            shift 1
            ;;
          light)
            colors+=("${COLOR_VARIANTS[1]}")
            shift 1
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[2]}")
            shift 1
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ "${image:-}" != 'true' ]]; then
  install_theme
fi

if [[ "${image:-}" == 'true'  ]]; then
  install_package && install_img && parse_sass && install_theme && restore_img && parse_sass
fi

echo
echo Done.
