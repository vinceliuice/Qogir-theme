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
THEME_VARIANTS=('' '-Manjaro' '-Ubuntu')
COLOR_VARIANTS=('' '-Light' '-Dark')
LOGO_NAME=''

image=''
window=''
square=''

theme_color='default'

SASSC_OPT="-M -t expanded"

if [[ "$(command -v gnome-shell)" ]]; then
  gnome-shell --version
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"
  if [[ "${SHELL_VERSION:-}" -ge "42" ]]; then
    GS_VERSION="42-0"
  elif [[ "${SHELL_VERSION:-}" -ge "40" ]]; then
    GS_VERSION="40-0"
  else
    GS_VERSION="3-32"
  fi
  else
    echo "'gnome-shell' not found, using styles for last gnome-shell version available."
    GS_VERSION="42-0"
fi

usage() {
cat << EOF
Usage: $0 [OPTION]...

OPTIONS:
  -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)

  -n, --name NAME         Specify theme name (Default: $THEME_NAME)

  -t, --theme VARIANT     Specify theme primary color variant(s) [default|manjaro|ubuntu|all] (Default: blue color)

  -c, --color VARIANT     Specify theme color variant(s) [standard|light|dark] (Default: All variants)

  -l, --logo VARIANT      Specify logo icon on nautilus [default|manjaro|ubuntu|fedora|debian|arch|gnome|budgie|popos|gentoo|void|zorin|mxlinux|opensuse] (Default: mountain icon)

  -g, --gdm               Install GDM theme, this option need root user authority! please run this with sudo

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
  local logo=${5}

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
  echo "IconTheme=${name}${theme}${ELSE_DARK}"                                    >> ${THEME_DIR}/index.theme
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

  if [[ -f ${SRC_DIR}/src/gtk/assets/logos/logo-${logo}.svg ]] ; then
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo-${logo}.svg                           ${THEME_DIR}/gtk-3.0/assets/logo.svg
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo@2-${logo}.svg                         ${THEME_DIR}/gtk-3.0/assets/logo@2.svg
  else
    echo "${logo} icon not supported, default icon will install..."
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

  if [[ -f ${SRC_DIR}/src/gtk/assets/logos/logo-${logo}.svg ]] ; then
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo-${logo}.svg                           ${THEME_DIR}/gtk-4.0/assets/logo.svg
    cp -r ${SRC_DIR}/src/gtk/assets/logos/logo@2-${logo}.svg                         ${THEME_DIR}/gtk-4.0/assets/logo@2.svg
  else
    echo "${logo} icon not supported, default icon will install..."
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

  # link gtk4.0 for libadwaita
  mkdir -p                                                                           ${HOME}/.config/gtk-4.0
  rm -rf ${HOME}/.config/gtk-4.0/{assets,gtk.css,gtk-dark.css}
  ln -sf ${THEME_DIR}/gtk-4.0/assets                                                 ${HOME}/.config/gtk-4.0/assets
  ln -sf ${THEME_DIR}/gtk-4.0/gtk.css                                                ${HOME}/.config/gtk-4.0/gtk.css
  ln -sf ${THEME_DIR}/gtk-4.0/gtk-dark.css                                           ${HOME}/.config/gtk-4.0/gtk-dark.css

  # GNOME SHELL
  mkdir -p                                                                           ${THEME_DIR}/gnome-shell
  cp -r ${SRC_DIR}/src/gnome-shell/common-assets                                     ${THEME_DIR}/gnome-shell/assets
  cp -r ${SRC_DIR}/src/gnome-shell/assets${theme}/{background.jpg,calendar-today.svg} ${THEME_DIR}/gnome-shell/assets
  cp -r ${SRC_DIR}/src/gnome-shell/assets${theme}/assets${ELSE_DARK}/*.svg           ${THEME_DIR}/gnome-shell/assets

  if [[ -f ${SRC_DIR}/src/gnome-shell/logos/logo-${logo}.svg ]] ; then
    cp -r ${SRC_DIR}/src/gnome-shell/logos/logo-${logo}.svg                          ${THEME_DIR}/gnome-shell/assets/activities.svg
  else
    echo "${logo} icon not supported, Qogir icon will install..."
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

# Backup and install files related to GDM theme
GS_THEME_FILE="/usr/share/gnome-shell/gnome-shell-theme.gresource"
SHELL_THEME_FOLDER="/usr/share/gnome-shell/theme"
UBUNTU_THEME_FILE="/usr/share/gnome-shell/theme/Yaru/gnome-shell-theme.gresource"
POP_OS_THEME_FILE="/usr/share/gnome-shell/theme/Pop/gnome-shell-theme.gresource"
ZORIN_THEME_FILE="/usr/share/gnome-shell/theme/ZorinBlue-Light/gnome-shell-theme.gresource"

install_gdm() {
  local GDM_THEME_DIR="${1}/${2}${3}${4}"

  if [[ -f "$GS_THEME_FILE" ]] && command -v glib-compile-resources >/dev/null ; then
    echo "Installing '$GS_THEME_FILE'..."
    cp -an "$GS_THEME_FILE" "$GS_THEME_FILE.bak"
    glib-compile-resources \
      --sourcedir="$GDM_THEME_DIR/gnome-shell" \
      --target="$GS_THEME_FILE" \
      "${SRC_DIR}/src/gnome-shell/gnome-shell-theme.gresource.xml"
  fi

  if [[ -f "$UBUNTU_THEME_FILE" ]]; then
    echo "Installing '$UBUNTU_THEME_FILE'..."
    cp -an "$UBUNTU_THEME_FILE" "$UBUNTU_THEME_FILE.bak"
    cp -rf "$GS_THEME_FILE" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$POP_OS_THEME_FILE" ]]; then
    echo "Installing '$POP_OS_THEME_FILE'..."
    cp -an "$POP_OS_THEME_FILE" "$POP_OS_THEME_FILE.bak"
    cp -rf "$GS_THEME_FILE" "$POP_OS_THEME_FILE"
  fi

  if [[ -f "$ZORIN_THEME_FILE" ]]; then
    echo "Installing '$ZORIN_THEME_FILE'..."
    cp -an "$ZORIN_THEME_FILE" "$ZORIN_THEME_FILE.bak"
    cp -rf "$GS_THEME_FILE" "$ZORIN_THEME_FILE"
  fi
}

revert_gdm() {
  if [[ -f "$GS_THEME_FILE.bak" ]]; then
    echo "reverting '$GS_THEME_FILE'..."
    rm -rf "$GS_THEME_FILE"
    mv "$GS_THEME_FILE.bak" "$GS_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_THEME_FILE.bak" ]]; then
    echo "reverting '$UBUNTU_THEME_FILE'..."
    rm -rf "$UBUNTU_THEME_FILE"
    mv "$UBUNTU_THEME_FILE.bak" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$POP_OS_THEME_FILE.bak" ]]; then
    echo "reverting '$POP_OS_THEME_FILE'..."
    rm -rf "$POP_OS_THEME_FILE"
    mv "$POP_OS_THEME_FILE.bak" "$POP_OS_THEME_FILE"
  fi

  if [[ -f "$ZORIN_THEME_FILE.bak" ]]; then
    echo "reverting '$ZORIN_THEME_FILE'..."
    rm -rf "$ZORIN_THEME_FILE"
    mv "$ZORIN_THEME_FILE.bak" "$ZORIN_THEME_FILE"
  fi
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
    -l|--logo)
      logo="${2}"
      shift 2
      ;;
    -g|--gdm)
      gdm='true'
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
            echo "ERROR: Unrecognized theme variant '$1'."
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
            echo "ERROR: Unrecognized tweak variant '$1'."
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

install_theme() {
  for theme in "${themes[@]-${THEME_VARIANTS[0]}}"; do
    for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
      install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${theme}" "${color}" "${logo:-${LOGO_NAME}}"
    done
  done

  for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    for screen in '' '-hdpi' '-xhdpi'; do
      install_xfwm "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${screen}"
    done
  done
}

uninstall_theme() {
  for theme in "${themes[@]-${THEME_VARIANTS[@]}}"; do
    for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
      for screen in '' '-hdpi' '-xhdpi'; do
        uninstall "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${theme}" "${color}" "${screen}"
      done
    done
  done

  [[ -L "${HOME}/.config/gtk-4.0/assets" ]] && rm -rf "${HOME}/.config/gtk-4.0/assets" && echo -e "Removing ${HOME}/.config/gtk-4.0/assets"
  [[ -L "${HOME}/.config/gtk-4.0/gtk.css" ]] && rm -rf "${HOME}/.config/gtk-4.0/gtk.css" && echo -e "Removing ${HOME}/.config/gtk-4.0/gtk.css"
  [[ -L "${HOME}/.config/gtk-4.0/gtk-dark.css" ]] && rm -rf "${HOME}/.config/gtk-4.0/gtk-dark.css" && echo -e "Removing ${HOME}/.config/gtk-4.0/gtk-dark.css"
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
    install_package; tweaks_temp
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

./clean-old-theme.sh

if [[ "${gdm:-}" != 'true' && "${remove:-}" != 'true' ]]; then
  install_theme
fi

if [[ "${gdm:-}" != 'true' && "${remove:-}" == 'true' ]]; then
  uninstall_theme
fi

if [[ "${gdm:-}" == 'true' && "${remove:-}" != 'true' && "$UID" -eq "$ROOT_UID" ]]; then
  install_theme && install_gdm "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${theme}" "${color}"
fi

if [[ "${gdm:-}" == 'true' && "${remove:-}" == 'true' && "$UID" -eq "$ROOT_UID" ]]; then
  revert_gdm
fi

echo -e "\nDone.\n"
