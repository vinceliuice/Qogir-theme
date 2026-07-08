#!/bin/bash
##
## ** macOS
##
## *** install optipng
## - For optipng install it with brew as follows:
## % brew install optipng
##
## *** install Inkscape
## - install Inkscape
##
## NOTE: If you have installed Inkscape on an other path then the default macOS /Applications path,
## for example if you have different versions of Inkscape, then you *have to* creat a Unix/Linux Symbol-Link
## (not a macOS Alias) to point to /Applications folder, like this:
##   % ln -s /Volumes/Apps/Graphic/inkscape.org/1.4.2/Inkscape.app  /Applications
##
## Inkscape is then accessible via command line like:
##   /Applications/Inkscape.app/Contents/MacOS/inkscape
## or where ever you installed it.
## Or make sure INKSCAPE is in your search path.
##
## *** Run this script:
##  % bash ./render-assets.sh
##

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine="Linux";;
    Darwin*)    machine="Mac";;
    CYGWIN*)    machine="Cygwin";;
    MINGW*)     machine="MinGw";;
    MSYS_NT*)   machine="MSys";;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo "${machine}"


if [ "x${machine}" == "xLinux" ]; then
    INKSCAPE="/usr/bin/inkscape"
    OPTIPNG="/usr/bin/optipng"
elif [ "x${machine}" == "xMac" ]; then
    INKSCAPE="/Applications/Inkscape.app/Contents/MacOS/inkscape"
    OPTIPNG="/usr/local/bin/optipng"
fi

INDEX="assets.txt"


OPEN_DIR=$(cd $(dirname $0) && pwd)

for win in '' '-Win'; do
  for color in '' '-Light'; do

  ASSETS_DIR="assets${win}${color}"
  SRC_FILE="assets${win}${color}.svg"

  mkdir -p $ASSETS_DIR

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

    ## Inkscape. Warning: Option --export-png= is deprecated
    ## --export-type=png

  fi

  done
  done
done

links() {
(
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
)
}

# links
cd "$OPEN_DIR/assets"
links

cd "$OPEN_DIR/assets-Light"
links

cd "$OPEN_DIR/assets-Win"
links

cd "$OPEN_DIR/assets-Light-Win"
links

exit 0
