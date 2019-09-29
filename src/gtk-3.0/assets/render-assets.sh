#! /bin/bash

INKSCAPE="/usr/bin/inkscape"
OPTIPNG="/usr/bin/optipng"

INDEX="assets.txt"

for theme in '' '-manjaro' '-ubuntu'; do

ASSETS_DIR="assets${theme}"
SRC_FILE="assets${theme}.svg"

for i in `cat $INDEX`
do

if [ -f $ASSETS_DIR/$i.png ]; then
    echo $ASSETS_DIR/$i.png exists.
else
    echo
    echo Rendering $ASSETS_DIR/$i.png
    $INKSCAPE --export-id=$i \
              --export-id-only \
              --export-png=$ASSETS_DIR/$i.png $SRC_FILE >/dev/null \
    && $OPTIPNG -o7 --quiet $ASSETS_DIR/$i.png 
fi

if [ -f $ASSETS_DIR/$i@2.png ]; then
    echo $ASSETS_DIR/$i@2.png exists.
else
    echo
    echo Rendering $ASSETS_DIR/$i@2.png
    $INKSCAPE --export-id=$i \
              --export-dpi=180 \
              --export-id-only \
              --export-png=$ASSETS_DIR/$i@2.png $SRC_FILE >/dev/null \
    && $OPTIPNG -o7 --quiet $ASSETS_DIR/$i@2.png 
fi

done
done

INDEX_COMMON="assets-common.txt"
ASSETS_COMMON_DIR="assets-common"
SRC_COMMON_FILE="assets-common.svg"

for i in `cat $INDEX_COMMON`
do

if [ -f $ASSETS_COMMON_DIR/$i.png ]; then
    echo $ASSETS_COMMON_DIR/$i.png exists.
else
    echo
    echo Rendering $ASSETS_COMMON_DIR/$i.png
    $INKSCAPE --export-id=$i \
              --export-id-only \
              --export-png=$ASSETS_COMMON_DIR/$i.png $SRC_COMMON_FILE >/dev/null \
    && $OPTIPNG -o7 --quiet $ASSETS_COMMON_DIR/$i.png 
fi

if [ -f $ASSETS_COMMON_DIR/$i@2.png ]; then
    echo $ASSETS_COMMON_DIR/$i@2.png exists.
else
    echo
    echo Rendering $ASSETS_COMMON_DIR/$i@2.png
    $INKSCAPE --export-id=$i \
              --export-dpi=180 \
              --export-id-only \
              --export-png=$ASSETS_COMMON_DIR/$i@2.png $SRC_COMMON_FILE >/dev/null \
    && $OPTIPNG -o7 --quiet $ASSETS_COMMON_DIR/$i@2.png 
fi

done

exit 0
