#! /bin/bash

INKSCAPE="/usr/bin/inkscape"
OPTIPNG="/usr/bin/optipng"

INDEX="assets.txt"

for theme in '' '-manjaro' '-ubuntu'; do
  for color in '' '-dark'; do

    ASSETS_DIR="assets${theme}${color}"
    SRC_FILE="assets${theme}${color}.svg"

    install -d $ASSETS_DIR

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
    done
  done
done

exit 0
