#! /bin/bash

THEME_DIR=$(cd $(dirname $0) && pwd)

THEME_NAME=Qogir

_THEME_VARIANTS=('' '-Manjaro' '-Ubuntu')

if [ ! -z "${THEME_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _THEME_VARIANTS <<< "${THEME_VARIANTS:-}"
fi


Tar_themes() {
  for theme in "${_THEME_VARIANTS[@]}"; do
    rm -rf ${THEME_NAME}${theme}.tar
    rm -rf ${THEME_NAME}${theme}.tar.xz
  done

  for theme in "${_THEME_VARIANTS[@]}"; do
    tar -Jcvf ${THEME_NAME}${theme}.tar.xz ${THEME_NAME}${theme}{'','-Light','-Dark'}
  done
}

Clear_theme() {
  for theme in "${_THEME_VARIANTS[@]}"; do
    rm -rf ${THEME_NAME}${theme}{'','-Light','-Dark'}{'','-hdpi','-xhdpi'}
  done
}

cd .. && ./install.sh -d $THEME_DIR -t all
cd $THEME_DIR && Tar_themes && Clear_theme

