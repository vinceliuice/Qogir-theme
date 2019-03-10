#! /bin/bash

INKSCAPE="/usr/bin/inkscape"
OPTIPNG="/usr/bin/optipng"
INDEX="assets.txt"

for color in '' '-light'; do
  for win in '' '-win'; do

  ASSETS_DIR="assets${color}${win}"
  SRC_FILE="assets${color}${win}.svg"

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

links() {
ln -s close.png close_focused.png
ln -s close.png close_focused_normal.png
ln -s close_focused_prelight.png close_unfocused_prelight.png
ln -s close_focused_pressed.png close_unfocused_pressed.png
ln -s maximize.png maximize_focused.png
ln -s maximize.png maximize_focused_normal.png
ln -s maximize_focused_prelight.png maximize_unfocused_prelight.png
ln -s maximize_focused_pressed.png maximize_unfocused_pressed.png
ln -s minimize.png minimize_focused.png
ln -s minimize.png minimize_focused_normal.png
ln -s minimize_focused_prelight.png minimize_unfocused_prelight.png
ln -s minimize_focused_pressed.png minimize_unfocused_pressed.png
ln -s unmaximize.png unmaximize_focused.png
ln -s unmaximize.png unmaximize_focused_normal.png
ln -s unmaximize_focused_prelight.png unmaximize_unfocused_prelight.png
ln -s unmaximize_focused_pressed.png unmaximize_unfocused_pressed.png
ln -s shade.png shade_focused.png
ln -s shade.png shade_focused_normal.png
ln -s shade_focused_prelight.png shade_unfocused_prelight.png
ln -s shade_focused_pressed.png shade_unfocused_pressed.png
ln -s unshade.png unshade_focused.png
ln -s unshade.png unshade_focused_normal.png
ln -s unshade_focused_prelight.png unshade_unfocused_prelight.png
ln -s unshade_focused_pressed.png unshade_unfocused_pressed.png
ln -s menu.png menu_focused.png
ln -s menu.png menu_focused_normal.png
ln -s menu_focused_prelight.png menu_unfocused_prelight.png
ln -s menu_focused_pressed.png menu_unfocused_pressed.png
}

# links
cd assets
links

cd ..
cd assets-light
links

cd ..
cd assets-win
links

cd ..
cd assets-light-win
links

exit 0
