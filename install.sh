#!/usr/bin/env bash

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
THEME_VARIANTS=('' '-Manjaro' '-Ubuntu')
COLOR_VARIANTS=('' '-Light' '-Dark')
ICON_NAME=''

image=''
window=''
square=''

theme_color='default'

SASSC_OPT="-M -t expanded"

if [[ "$(command -v gnome-shell)" ]]; then
  gnome-shell --version
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"
  if [[ "${SHELL_VERSION:-}" -ge "44" ]]; then
    GS_VERSION="44-0"
  elif [[ "${SHELL_VERSION:-}" -ge "42" ]]; then
    GS_VERSION="42-0"
  elif [[ "${SHELL_VERSION:-}" -ge "40" ]]; then
    GS_VERSION="40-0"
  else
    GS_VERSION="3-32"
  fi
  else
    echo "'gnome-shell' not found, using styles for last gnome-shell version available."
    GS_VERSION="44-0"
fi

usage() {
cat << EOF
Usage: $0 [OPTION]...

OPTIONS:
  -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)

  -n, --name NAME         Specify theme name (Default: $THEME_NAME)

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
EOF
}

install() {
  local dest=${1}
  local name=${2}
  local theme=${3}
  local color=${4}
  local icon=${5}

  [[ ${color} == '-Dark' ]] && local ELSE_DARK=${color}
  [[ ${color} == '-Light' ]] && local ELSE_LIGHT=${color}

  local THEME_DIR=${dest}/${name}${theme}${color}

  [[ -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  theme_tweaks && install_theme_color

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                           ${THEME_DIR}
  cp -r ${SRC_DIR}/COPYING                                                           ${THEME_DIR}
  cp -r ${SRC_DIR}/AUTHORS                                                           ${THEME_DIR}

  echo "[Desktop Entry]"                                                          >> ${THEME_DIR}/index.theme
  echo "Type=X-GNOME-Metatheme"                                                   >> ${THEME_DIR}/index.theme
  echo "Name=${name}${theme}${color}"                                             >> ${THEME_DIR}/index.theme
  echo "Comment=An Clean Gtk+ theme based on Flat Design"                         >> ${THEME_DIR}/index.theme
  echo "Encoding=UTF-8"                                                           >> ${THEME_DIR}/index.theme
  echo ""                                                                         >> ${THEME_DIR}/index.theme
  echo "[X-GNOME-Metatheme]"                                                      >> ${THEME_DIR}/index.theme
  echo "GtkTheme=${name}${theme}${color}"                                         >> ${THEME_DIR}/index.theme
  echo "MetacityTheme=${name}${theme}${color}"                                    >> ${THEME_DIR}/index.theme
  echo "IconTheme=${name}${theme,,}${ELSE_DARK,,}"                                >> ${THEME_DIR}/index.theme
  echo "CursorTheme=Adwaita"                                                      >> ${THEME_DIR}/index.theme
  echo "ButtonLayout=menu:minimize,maximize,close"                                >> ${THEME_DIR}/index.theme

  # GTK 2.0
  mkdir -p                                                                           ${THEME_DIR}/gtk-2.0
  cp -r ${SRC_DIR}/src/gtk-2.0/{apps.rc,panel.rc,main.rc,xfce-notify.rc}             ${THEME_DIR}/gtk-2.0
  cp -r ${SRC_DIR}/src/gtk-2.0/assets/assets${theme}${ELSE_DARK}                     ${THEME_DIR}/gtk-2.0/assets
  cp -r ${SRC_DIR}/src/gtk-2.0/theme${theme}/gtkrc${color}                           ${THEME_DIR}/gtk-2.0/gtkrc
  cp -r ${SRC_DIR}/src/gtk-2.0/menubar-toolbar${color}.rc                            ${THEME_DIR}/gtk-2.0/menubar-toolbar.rc

  # GTK 3.0
  mkdir -p                                                                           ${THEME_DIR}/gtk-3.0
  cp -r ${SRC_DIR}/src/gtk/assets/assets${theme}                                     ${THEME_DIR}/gtk-3.0/assets

  if [[ -f ${SRC_DIR}/src/gtk/assets/logos/logo-${icon}.svg ]] ; then
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo-${icon}.svg                           ${THEME_DIR}/gtk-3.0/assets/logo.svg
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo@2-${icon}.svg                         ${THEME_DIR}/gtk-3.0/assets/logo@2.svg
  else
    echo "${icon} icon not supported, default icon will install..."
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo-.svg                                  ${THEME_DIR}/gtk-3.0/assets/logo.svg
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo@2-.svg                                ${THEME_DIR}/gtk-3.0/assets/logo@2.svg
  fi

  cp -r ${SRC_DIR}/src/gtk/assets/assets-common/*                                    ${THEME_DIR}/gtk-3.0/assets

  if [[ "$tweaks" == 'true' ]]; then
    sassc $SASSC_OPT ${SRC_DIR}/src/gtk/theme-3.0/gtk${color}.scss                   ${THEME_DIR}/gtk-3.0/gtk.css
    sassc $SASSC_OPT ${SRC_DIR}/src/gtk/theme-3.0/gtk-Dark.scss                      ${THEME_DIR}/gtk-3.0/gtk-dark.css
  else
    cp -r ${SRC_DIR}/src/gtk/theme-3.0/gtk${color}.css                               ${THEME_DIR}/gtk-3.0/gtk.css
    cp -r ${SRC_DIR}/src/gtk/theme-3.0/gtk-Dark.css                                  ${THEME_DIR}/gtk-3.0/gtk-dark.css
  fi

  cp -r ${SRC_DIR}/src/gtk/assets/thumbnail${theme}${ELSE_DARK}.png                  ${THEME_DIR}/gtk-3.0/thumbnail.png

  # GTK 4.0
  mkdir -p                                                                           ${THEME_DIR}/gtk-4.0
  cp -r ${SRC_DIR}/src/gtk/assets/assets${theme}                                     ${THEME_DIR}/gtk-4.0/assets

  if [[ -f ${SRC_DIR}/src/gtk/assets/logos/logo-${icon}.svg ]] ; then
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo-${icon}.svg                           ${THEME_DIR}/gtk-4.0/assets/logo.svg
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo@2-${icon}.svg                         ${THEME_DIR}/gtk-4.0/assets/logo@2.svg
  else
    echo "${icon} icon not supported, default icon will install..."
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo-.svg                                  ${THEME_DIR}/gtk-4.0/assets/logo.svg
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo@2-.svg                                ${THEME_DIR}/gtk-4.0/assets/logo@2.svg
  fi

  cp -r ${SRC_DIR}/src/gtk/assets/assets-common/*                                    ${THEME_DIR}/gtk-4.0/assets

  if [[ "$tweaks" == 'true' ]]; then
    sassc $SASSC_OPT ${SRC_DIR}/src/gtk/theme-4.0/gtk${color}.scss                   ${THEME_DIR}/gtk-4.0/gtk.css
    sassc $SASSC_OPT ${SRC_DIR}/src/gtk/theme-4.0/gtk-Dark.scss                      ${THEME_DIR}/gtk-4.0/gtk-dark.css
  else
    cp -r ${SRC_DIR}/src/gtk/theme-4.0/gtk${color}.css                               ${THEME_DIR}/gtk-4.0/gtk.css
    cp -r ${SRC_DIR}/src/gtk/theme-4.0/gtk-Dark.css                                  ${THEME_DIR}/gtk-4.0/gtk-dark.css
  fi

  cp -r ${SRC_DIR}/src/gtk/assets/thumbnail${theme}${ELSE_DARK}.png                  ${THEME_DIR}/gtk-4.0/thumbnail.png

  # GNOME SHELL
  mkdir -p                                                                           ${THEME_DIR}/gnome-shell
  cp -r ${SRC_DIR}/src/gnome-shell/common-assets                                     ${THEME_DIR}/gnome-shell/assets
  cp -r ${SRC_DIR}/src/gnome-shell/assets${theme}/{background.jpg,calendar-today.svg} ${THEME_DIR}/gnome-shell/assets
  cp -r ${SRC_DIR}/src/gnome-shell/assets${theme}/assets${ELSE_DARK}/*.svg           ${THEME_DIR}/gnome-shell/assets

  if [[ -f ${SRC_DIR}/src/gnome-shell/logos/logo-${icon}.svg ]] ; then
    cp -r ${SRC_DIR}/src/gnome-shell/logos/logo-${icon}.svg                          ${THEME_DIR}/gnome-shell/assets/activities.svg
  else
    echo "${icon} icon not supported, Qogir icon will install..."
    cp -r ${SRC_DIR}/src/gnome-shell/logos/logo-qogir.svg                            ${THEME_DIR}/gnome-shell/assets/activities.svg
  fi

  cp -r ${SRC_DIR}/src/gnome-shell/icons                                             ${THEME_DIR}/gnome-shell
  cp -r ${SRC_DIR}/src/gnome-shell/pad-osd.css                                       ${THEME_DIR}/gnome-shell


  if [[ "$tweaks" == 'true' ]]; then
    sassc $SASSC_OPT ${SRC_DIR}/src/gnome-shell/theme-${GS_VERSION}/gnome-shell${ELSE_DARK}.scss ${THEME_DIR}/gnome-shell/gnome-shell.css
  else
    cp -r ${SRC_DIR}/src/gnome-shell/theme-${GS_VERSION}/gnome-shell${ELSE_DARK}.css ${THEME_DIR}/gnome-shell/gnome-shell.css
  fi

  cd ${THEME_DIR}/gnome-shell
  ln -sf assets/no-events.svg no-events.svg
  ln -sf assets/process-working.svg process-working.svg
  ln -sf assets/no-notifications.svg no-notifications.svg

  # CINNAMON
  mkdir -p                                                                           ${THEME_DIR}/cinnamon
  cp -r ${SRC_DIR}/src/cinnamon/assets${theme}/common-assets                         ${THEME_DIR}/cinnamon
  cp -r ${SRC_DIR}/src/cinnamon/assets${theme}/assets${ELSE_DARK}                    ${THEME_DIR}/cinnamon/assets
  if [[ "$tweaks" == 'true' ]]; then
    sassc $SASSC_OPT ${SRC_DIR}/src/cinnamon/cinnamon${ELSE_DARK}.scss               ${THEME_DIR}/cinnamon/cinnamon.css
  else
    cp -r ${SRC_DIR}/src/cinnamon/cinnamon${ELSE_DARK}.css                           ${THEME_DIR}/cinnamon/cinnamon.css
  fi

  cp -r ${SRC_DIR}/src/cinnamon/thumbnail${theme}${ELSE_DARK}.png                    ${THEME_DIR}/cinnamon/thumbnail.png

  # METACITY
  mkdir -p                                                                           ${THEME_DIR}/metacity-1

  if [[ "$window" == 'round' ]]; then
    cp -r ${SRC_DIR}/src/metacity-1/assets-Round                                     ${THEME_DIR}/metacity-1/assets
    cp -r ${SRC_DIR}/src/metacity-1/metacity-theme-3-Round.xml                       ${THEME_DIR}/metacity-1/metacity-theme-3.xml
    cp -r ${SRC_DIR}/src/metacity-1/metacity-theme-1${ELSE_LIGHT}-Round.xml          ${THEME_DIR}/metacity-1/metacity-theme-1.xml
  else
    if [[ "$square" == 'true' ]]; then
      cp -r ${SRC_DIR}/src/metacity-1/assets${ELSE_LIGHT}-Win/*.png                  ${THEME_DIR}/metacity-1
      cp -r ${SRC_DIR}/src/metacity-1/metacity-theme-3-Win.xml                       ${THEME_DIR}/metacity-1/metacity-theme-3.xml
      cp -r ${SRC_DIR}/src/metacity-1/metacity-theme-1${ELSE_LIGHT}-Win.xml          ${THEME_DIR}/metacity-1/metacity-theme-1.xml
    else
      cp -r ${SRC_DIR}/src/metacity-1/assets${ELSE_LIGHT}/*.png                      ${THEME_DIR}/metacity-1
      cp -r ${SRC_DIR}/src/metacity-1/metacity-theme-3.xml                           ${THEME_DIR}/metacity-1/metacity-theme-3.xml
      cp -r ${SRC_DIR}/src/metacity-1/metacity-theme-1${ELSE_LIGHT}.xml              ${THEME_DIR}/metacity-1/metacity-theme-1.xml
    fi
  fi

  cp -r ${SRC_DIR}/src/metacity-1/thumbnail${ELSE_LIGHT}.png                         ${THEME_DIR}/metacity-1/thumbnail.png
  cd ${THEME_DIR}/metacity-1
  ln -s metacity-theme-1.xml metacity-theme-2.xml

  # OTHER
  cp -r ${SRC_DIR}/src/plank                                                         ${THEME_DIR}
  cp -r ${SRC_DIR}/src/unity                                                         ${THEME_DIR}
  cp -r ${SRC_DIR}/src/xfce-notify-4.0                                               ${THEME_DIR}
}

install_xfwm() {
  local dest=${1}
  local name=${2}
  local color=${3}
  local screen=${4}

  [[ ${color} == '-Dark' ]] && local ELSE_DARK=${color}
  [[ ${color} == '-Light' ]] && local ELSE_LIGHT=${color}

  local THEME_DIR=${dest}/${name}${color}${screen}

  [[ ${screen} != '' && -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  # XFWM4
  mkdir -p                                                                           ${THEME_DIR}/xfwm4

  if [[ "$square" == 'true' ]]; then
    cp -r ${SRC_DIR}/src/xfwm4/themerc-Win${ELSE_LIGHT}                              ${THEME_DIR}/xfwm4/themerc
    cp -r ${SRC_DIR}/src/xfwm4/assets-Win${ELSE_LIGHT}${screen}/*.png                ${THEME_DIR}/xfwm4
  else
    cp -r ${SRC_DIR}/src/xfwm4/themerc${ELSE_LIGHT}                                  ${THEME_DIR}/xfwm4/themerc
    cp -r ${SRC_DIR}/src/xfwm4/assets${ELSE_LIGHT}${screen}/*.png                    ${THEME_DIR}/xfwm4
  fi
}

uninstall() {
  local dest=${1}
  local name=${2}
  local theme=${3}
  local color=${4}
  local screen=${5}

  local THEME_DIR=${dest}/${name}${theme}${color}${screen}

  [[ -d "$THEME_DIR" ]] && rm -rf "$THEME_DIR" && echo -e "Uninstalling "$THEME_DIR" ..."
}

# GDM Theme

check_exist() {
  [[ -f "${1}" || -f "${1}.bak" ]]
}

restore_file() {
  if [[ -f "${1}.bak" || -d "${1}.bak" ]]; then
    rm -rf "${1}"; mv "${1}"{".bak",""}
  fi
}

backup_file() {
  if [[ -f "${1}" || -d "${1}" ]]; then
    mv -n "${1}"{"",".bak"}
  fi
}

install_gdm_deps() {
  if ! has_command glib-compile-resources; then
    echo -e "\n'glib2.0' are required for theme installation."

    if has_command zypper; then
      sudo zypper in -y glib2-devel
    elif has_command swupd; then
      sudo swupd bundle-add libglib
    elif has_command apt; then
      sudo apt install libglib2.0-dev-bin
    elif has_command dnf; then
      sudo dnf install -y glib2-devel
    elif has_command yum; then
      sudo yum install -y glib2-devel
    elif has_command pacman; then
      sudo pacman -Syyu --noconfirm --needed glib2
    elif has_command xbps-install; then
      sudo xbps-install -Sy glib-devel
    elif has_command eopkg; then
      sudo eopkg -y install glib2
    else
      echo -e "\nWARNING: We're sorry, your distro isn't officially supported yet.\n"
    fi
  fi
}

GS_THEME_DIR="/usr/share/gnome-shell/theme"
COMMON_CSS_FILE="/usr/share/gnome-shell/theme/gnome-shell.css"
UBUNTU_CSS_FILE="/usr/share/gnome-shell/theme/ubuntu.css"
ZORIN_CSS_FILE="/usr/share/gnome-shell/theme/zorin.css"
ETC_CSS_FILE="/etc/alternatives/gdm3.css"
ETC_GR_FILE="/etc/alternatives/gdm3-theme.gresource"
YARU_GR_FILE="/usr/share/gnome-shell/theme/Yaru/gnome-shell-theme.gresource"
POP_OS_GR_FILE="/usr/share/gnome-shell/theme/Pop/gnome-shell-theme.gresource"
ZORIN_GR_FILE="/usr/share/gnome-shell/theme/ZorinBlue-Light/gnome-shell-theme.gresource"
MISC_GR_FILE="/usr/share/gnome-shell/gnome-shell-theme.gresource"
GS_GR_XML_FILE="${SRC_DIR}/src/gnome-shell/gnome-shell-theme.gresource.xml"

install_gdm() {
  local name="${1}"
  local theme="${2}"
  local gcolor="${3}"
  local icon="${4}"
  local TARGET=

  [[ "${gcolor}" == '-Light' ]] && local ELSE_LIGHT="${gcolor}"
  [[ "${gcolor}" == '-Dark' ]] && local ELSE_DARK="${gcolor}"

  local THEME_TEMP="/tmp/${1}${2}${3}"

  theme_tweaks && install_gdm_deps && install_theme_color

  echo -e "\nInstall ${1}${2}${3} GDM Theme..."

  rm -rf "${THEME_TEMP}"
  mkdir -p                                                                                  "${THEME_TEMP}/gnome-shell"
  cp -r "${SRC_DIR}/src/gnome-shell/common-assets"                                          "${THEME_TEMP}/gnome-shell/assets"
  cp -r "${SRC_DIR}/src/gnome-shell/assets${theme}/"{background.jpg,calendar-today.svg}     "${THEME_TEMP}/gnome-shell/assets"
  cp -r "${SRC_DIR}/src/gnome-shell/assets${theme}/assets${ELSE_DARK}/"*.svg                "${THEME_TEMP}/gnome-shell/assets"
  mv "${THEME_TEMP}/gnome-shell/assets/"{process-working.svg,no-events.svg,no-notifications.svg} "${THEME_TEMP}/gnome-shell"

  if [[ -f "${SRC_DIR}/src/gnome-shell/logos/logo-${icon}.svg" ]] ; then
    cp -r "${SRC_DIR}/src/gnome-shell/logos/logo-${icon}.svg"                               "${THEME_TEMP}/gnome-shell/assets/activities.svg"
  else
    echo "${icon} icon not supported, Qogir icon will install..."
    cp -r "${SRC_DIR}/src/gnome-shell/logos/logo-qogir.svg"                                 "${THEME_TEMP}/gnome-shell/assets/activities.svg"
  fi

  cp -r "${SRC_DIR}/src/gnome-shell/icons"                                                  "${THEME_TEMP}/gnome-shell"
  cp -r "${SRC_DIR}/src/gnome-shell/pad-osd.css"                                            "${THEME_TEMP}/gnome-shell"

  if [[ "$tweaks" == 'true' ]]; then
    sassc $SASSC_OPT "${SRC_DIR}/src/gnome-shell/theme-${GS_VERSION}/gnome-shell${ELSE_DARK}.scss" "${THEME_TEMP}/gnome-shell/gnome-shell.css"
  else
    cp -r "${SRC_DIR}/src/gnome-shell/theme-${GS_VERSION}/gnome-shell${ELSE_DARK}.css" "${THEME_TEMP}/gnome-shell/gnome-shell.css"
  fi

  if check_exist "${COMMON_CSS_FILE}"; then # CSS-based theme
    if check_exist "${UBUNTU_CSS_FILE}"; then
      TARGET="${UBUNTU_CSS_FILE}"
    elif check_exist "${ZORIN_CSS_FILE}"; then
      TARGET="${ZORIN_CSS_FILE}"
    fi

    backup_file "${COMMON_CSS_FILE}"; backup_file "${TARGET}"

    if check_exist "${GS_THEME_DIR}/${name}"; then
      rm -rf "${GS_THEME_DIR}/${name}"
    fi

    cp -rf "${THEME_TEMP}/gnome-shell"                                                       "${GS_THEME_DIR}/${name}"
    ln -sf "${GS_THEME_DIR}/${name}/gnome-shell.css"                                         "${COMMON_CSS_FILE}"
    ln -sf "${GS_THEME_DIR}/${name}/gnome-shell.css"                                         "${TARGET}"

    # Fix previously installed theme
    restore_file "${ETC_CSS_FILE}"
  else # GR-based theme
    if check_exist "$POP_OS_GR_FILE"; then
      TARGET="${POP_OS_GR_FILE}"
    elif check_exist "$YARU_GR_FILE"; then
      TARGET="${YARU_GR_FILE}"
    elif check_exist "$ZORIN_GR_FILE"; then
      TARGET="${ZORIN_GR_FILE}"
    elif check_exist "$MISC_GR_FILE"; then
      TARGET="${MISC_GR_FILE}"
    fi

    backup_file "${TARGET}"
    glib-compile-resources --sourcedir="${THEME_TEMP}/gnome-shell" --target="${TARGET}" "${GS_GR_XML_FILE}"

    # Fix previously installed theme
    restore_file "${ETC_GR_FILE}"
  fi
}

uninstall_gdm_theme() {
  rm -rf "${GS_THEME_DIR}/$THEME_NAME"
  restore_file "${COMMON_CSS_FILE}"; restore_file "${UBUNTU_CSS_FILE}"
  restore_file "${ZORIN_CSS_FILE}"; restore_file "${ETC_CSS_FILE}"
  restore_file "${POP_OS_GR_FILE}"; restore_file "${YARU_GR_FILE}"
  restore_file "${MISC_GR_FILE}"; restore_file "${ETC_GR_FILE}"
  restore_file "${ZORIN_GR_FILE}"
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo -e "ERROR: Destination directory does not exist."
        exit 1
      fi
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -i|--icon)
      icon="${2}"
      shift 2
      ;;
    -g|--gdm)
      gdm='true'
      shift
      ;;
    -l|--libadwaita)
      libadwaita='true'
      shift
      ;;
    -r|--remove|-u|--uninstall)
      remove='true'
      shift
      ;;
    -t|--theme)
      accent='true'
      shift
      for theme in "${@}"; do
        case "${theme}" in
          default)
            themes+=("${THEME_VARIANTS[0]}")
            shift 1
            ;;
          manjaro)
            themes+=("${THEME_VARIANTS[1]}")
            shift 1
            ;;
          ubuntu)
            themes+=("${THEME_VARIANTS[2]}")
            shift 1
            ;;
          all)
            themes+=("${THEME_VARIANTS[@]}")
            shift 1
            ;;
          -*|--*)
            break
            ;;
          *)
            echo -e "ERROR: Unrecognized theme variant '$1'."
            echo -e "Try '$0 --help' for more information."
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
            lcolors+=("${COLOR_VARIANTS[0]}")
            gcolors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          light)
            colors+=("${COLOR_VARIANTS[1]}")
            lcolors+=("${COLOR_VARIANTS[1]}")
            gcolors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[2]}")
            lcolors+=("${COLOR_VARIANTS[2]}")
            gcolors+=("${COLOR_VARIANTS[2]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo -e "ERROR: Unrecognized color variant '$1'."
            echo -e "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    --tweaks)
      shift
      for tweak in "${@}"; do
        case "${tweak}" in
          image)
            image='true'
            shift
            ;;
          round)
            window='round'
            shift
            ;;
          square)
            square='true'
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo -e "ERROR: Unrecognized tweak variant '$1'."
            echo -e "Try '$0 --help' for more information."
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
      echo -e "ERROR: Unrecognized installation option '$1'."
      echo -e "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

# check command avalibility
function has_command() {
  command -v $1 > /dev/null
}

install_css_deps() {
  if [ ! "$(which sassc 2> /dev/null)" ]; then
    echo -e "\n sassc needs to be installed to generate the css."

    if has_command zypper; then

      read -p "[ trusted ] specify the root password : " -t 20 -s
      [[ -n "$REPLY" ]] && {
        echo -e "\n running: sudo zypper in sassc "
        sudo -S <<< $REPLY zypper in sassc
      }|| {
        echo -e "\n Operation canceled  Bye"
        exit 1
      }

      elif has_command apt; then

      read -p "[ trusted ] specify the root password : " -t 20 -s
      [[ -n "$REPLY" ]] && {
        echo -e "\n running: sudo apt install --assume-yes sassc "
        sudo -S <<< $REPLY apt install --assume-yes sassc
      }|| {
        echo -e "\n Operation canceled  Bye"
        exit 1
      }

      elif has_command dnf; then

      read -p "[ trusted ] specify the root password : " -t 20 -s
      [[ -n "$REPLY" ]] && {
        echo -e "\n running: sudo dnf install sassc "
        sudo -S <<< $REPLY dnf install sassc
      }|| {
        echo -e "\n Operation canceled  Bye"
        exit 1
      }

      elif has_command yum; then

      read -p "[ trusted ] specify the root password : " -t 20 -s
      [[ -n "$REPLY" ]] && {
        echo -e "\n running: sudo yum install sassc "
        sudo -S <<< $REPLY yum install sassc
      }|| {
        echo -e "\n Operation canceled  Bye"
        exit 1
      }

      elif has_command pacman; then

      read -p "[ trusted ] specify the root password : " -t 20 -s
      [[ -n "$REPLY" ]] && {
        echo -e "\n running: sudo pacman -S --noconfirm sassc "
        sudo -S <<< $REPLY pacman -S --noconfirm sassc
      }|| {
        echo -e "\n Operation canceled  Bye"
        exit 1
      }

    fi
  fi
}

uninstall_link() {
  rm -rf "${HOME}/.config/gtk-4.0"/{assets,gtk.css,gtk-dark.css}
}

link_libadwaita() {
  local dest="${1}"
  local name="${2}"
  local theme="${3}"
  local lcolor="${4}"

  local THEME_DIR="${1}/${2}${3}${4}"

  echo -e "\nLink '$THEME_DIR/gtk-4.0' to '${HOME}/.config/gtk-4.0' for libadwaita..."

  mkdir -p                                                                      "${HOME}/.config/gtk-4.0"
  ln -sf "${THEME_DIR}/gtk-4.0/assets"                                          "${HOME}/.config/gtk-4.0/assets"
  ln -sf "${THEME_DIR}/gtk-4.0/gtk.css"                                         "${HOME}/.config/gtk-4.0/gtk.css"
  ln -sf "${THEME_DIR}/gtk-4.0/gtk-dark.css"                                    "${HOME}/.config/gtk-4.0/gtk-dark.css"
}

tweaks_temp() {
  cp -rf ${SRC_DIR}/src/_sass/_tweaks.scss ${SRC_DIR}/src/_sass/_tweaks-temp.scss
}

install_image() {
  sed -i "/\$background:/s/default/image/" ${SRC_DIR}/src/_sass/_tweaks-temp.scss
  echo -e "Install Nautilus with background image version ..."
}

install_win_titlebutton() {
  sed -i "/\$titlebutton:/s/circle/square/" ${SRC_DIR}/src/_sass/_tweaks-temp.scss
  echo -e "Install Square titlebutton version ..."
}

install_round_window() {
  sed -i "/\$window:/s/default/round/" ${SRC_DIR}/src/_sass/_tweaks-temp.scss
  echo -e "Install Round window version ..."
}

install_theme_color() {
  if [[ "$theme" != '' ]]; then
    case "$theme" in
      -Manjaro)
        theme_color='manjaro'
        ;;
      -Ubuntu)
        theme_color='ubuntu'
        ;;
    esac
    sed -i "/\$theme:/s/default/${theme_color}/" ${SRC_DIR}/src/_sass/_tweaks-temp.scss
  fi
}

theme_tweaks() {
  if [[ "$image" == "true" || "$square" == "true" || "$accent" == 'true' || "$window" == 'round' ]]; then
    tweaks='true'
    install_css_deps; tweaks_temp
  fi

  if [[ "$image" == "true" ]] ; then
    install_image
  fi

  if [[ "$square" == "true" ]] ; then
    install_win_titlebutton
  fi

  if [[ "$window" == "round" ]] ; then
    install_round_window
  fi
}

link_theme() {
  for theme in "${themes[@]-${THEME_VARIANTS[0]}}"; do
    for lcolor in "${lcolors[@]-${COLOR_VARIANTS[1]}}"; do
      link_libadwaita "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "$theme" "$lcolor"
    done
  done
}

install_theme() {
  for theme in "${themes[@]-${THEME_VARIANTS[0]}}"; do
    for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
      install "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "${theme}" "${color}" "${icon:-${ICON_NAME}}"
    done
  done

  for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    for screen in '' '-hdpi' '-xhdpi'; do
      install_xfwm "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "${color}" "${screen}"
    done
  done
}

uninstall_theme() {
  for theme in "${themes[@]-${THEME_VARIANTS[@]}}"; do
    for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
      for screen in '' '-hdpi' '-xhdpi'; do
        uninstall "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "${theme}" "${color}" "${screen}"
      done
    done
  done
}

./clean-old-theme.sh

if [[ "${gdm:-}" != 'true' && "${remove:-}" != 'true' ]]; then
  install_theme

  if [[ "$libadwaita" == 'true' ]]; then
    uninstall_link && link_theme
  fi
fi

if [[ "${gdm:-}" != 'true' && "${remove:-}" == 'true' ]]; then
  if [[ "$libadwaita" == 'true' ]]; then
    echo -e "\nUninstall ${HOME}/.config/gtk-4.0 links ..."
    uninstall_link
  else
    echo && uninstall_theme && uninstall_link
  fi
fi

if [[ "${gdm:-}" == 'true' && "${remove:-}" != 'true' && "$UID" -eq "$ROOT_UID" ]]; then
  if [[ "${#gcolors[@]}" -gt 1 ]]; then
    echo -e 'Error: To install a gdm theme you can only select one color'
    exit 1
  fi

  if [[ "${#themes[@]}" -gt 1 ]]; then
    echo -e 'Error: To install a gdm theme you can only select one theme'
    exit 1
  fi

  echo -e "\nNOTICE: Only GDM theme will installed..."

  for theme in "${themes[@]-${THEME_VARIANTS[0]}}"; do
    for gcolor in "${gcolors[@]-${COLOR_VARIANTS[2]}}"; do
      install_gdm "${name:-${THEME_NAME}}" "${theme}" "${gcolor}" "${icon:-${ICON_NAME}}"
    done
  done
fi

if [[ "${gdm:-}" == 'true' && "${remove:-}" == 'true' && "$UID" -eq "$ROOT_UID" ]]; then
  uninstall_gdm_theme
fi

if [[ "${gdm:-}" == 'true' && "$UID" != "$ROOT_UID" ]]; then
  echo -e 'Error: need run it with sudo !'
  exit 0
fi

echo -e "\nDone.\n"
