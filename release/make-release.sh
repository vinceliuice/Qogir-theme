#! /bin/bash

THEME_DIR=$(cd $(dirname $0) && pwd)

THEME_NAME=Qogir

_THEME_VARIANTS=('' '-Manjaro' '-Ubuntu')
_WINDOW_VARIANTS=('' '-Round')

if [ ! -z "${THEME_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _THEME_VARIANTS <<< "${THEME_VARIANTS:-}"
fi

if [ ! -z "${WINDOW_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _WINDOW_VARIANTS <<< "${WINDOW_VARIANTS:-}"
fi

Tar_themes() {
  for theme in "${_THEME_VARIANTS[@]}"; do
    for window in "${_WINDOW_VARIANTS[@]}"; do
      rm -rf ${THEME_NAME}${theme}${window}.tar
      rm -rf ${THEME_NAME}${theme}${window}.tar.xz
    done
  done

  for theme in "${_THEME_VARIANTS[@]}"; do
    for window in "${_WINDOW_VARIANTS[@]}"; do
      tar -Jcvf ${THEME_NAME}${theme}${window}.tar.xz ${THEME_NAME}${theme}${window}{'','-Light','-Dark'}
    done
  done
}

Clear_theme() {
  for theme in "${_THEME_VARIANTS[@]}"; do
    rm -rf ${THEME_NAME}${theme}{'','-Round'}{'','-Light','-Dark'}{'','-hdpi','-xhdpi'}
  done
}

cd .. && ./install.sh -d $THEME_DIR -t all && ./install.sh -d $THEME_DIR -t all --tweaks round
cd $THEME_DIR && Tar_themes && Clear_theme

