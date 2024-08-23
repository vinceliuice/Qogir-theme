#!/bin/bash

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

THEME_NAME=Qogir
THEME_VARIANTS=('' '-manjaro' '-ubuntu')
COLOR_VARIANTS=('' '-light' '-dark')
N_THEME_VARIANTS=('' '-Manjaro' '-Ubuntu')
N_COLOR_VARIANTS=('' '-Light' '-Dark')

clean() {
  local dest=${1}
  local name=${2}
  local theme=${3}
  local color=${4}

  local THEME_DIR="${dest}/${name}${theme}${color}"

  if [[ -d "${THEME_DIR}" ]]; then
    if [[ "${theme}" == '' && "${color}" == '' ]]; then
      nothing='true'
    else
      rm -rf "${THEME_DIR}"{'','-hdpi','-xhdpi'}
      echo -e "Find: ${THEME_DIR} ! removing it ..."
    fi
  fi
}

clean_theme() {
  for theme in "${themes[@]-${THEME_VARIANTS[@]}}"; do
    for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
      clean "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${theme}" "${color}"
    done
  done

  local dest="$HOME/.local/share/themes"

  for theme in "${themes[@]-${N_THEME_VARIANTS[@]}}"; do
    for color in "${colors[@]-${N_COLOR_VARIANTS[@]}}"; do
      clean "${dest}" "${name:-${THEME_NAME}}" "${theme}" "${color}"
    done
  done
}

clean_theme

exit 0
