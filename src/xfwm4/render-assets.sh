#! /bin/bash

INKSCAPE="/usr/bin/inkscape"
OPTIPNG="/usr/bin/optipng"

INDEX="assets.txt"

for wmbutton in '' '-Win'; do
  for window in '' '-Round'; do
    for color in '' '-Light'; do
      for screen in '' '-hdpi' '-xhdpi'; do
        for i in `cat $INDEX`; do

        ASSETS_DIR="assets${wmbutton}${window}${color}${screen}"
        SRC_FILE="assets${wmbutton}${window}${color}.svg"

        mkdir -p $ASSETS_DIR

        case "${screen}" in
          -hdpi)
            dpi='144'
            ;;
          -xhdpi)
            dpi='192'
            ;;
          *)
            dpi='96'
            ;;
        esac

        if [ -f $ASSETS_DIR/$i.png ]; then
          echo $ASSETS_DIR/$i.png exists.
        else
          echo
          echo Rendering $ASSETS_DIR/$i.png
          $INKSCAPE --export-id=$i \
                    --export-id-only \
                    --export-dpi=$dpi \
                    --export-filename=$ASSETS_DIR/$i.png $SRC_FILE >/dev/null \
          && $OPTIPNG -o7 --quiet $ASSETS_DIR/$i.png 
        fi

        done
      done
    done
  done
done

exit 0
