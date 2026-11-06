# Slices the Busan panorama across both monitors so it reads as one image.
# Crops are taken in the Wayland logical layout, where both screens share a
# physical scale (DP-2 1440p at 1x on the left, DP-3 4K at 1.25x on the right).
# left.png/right.png are per-output at native resolution.
{ runCommand, imagemagick }:

let
  # The photo is scaled past the combined logical width (5632) so the right
  # edge's building and trees fall off; x0 trims a little from the left too.
  width = 7000;
  x0 = 150;
  # Rows of sky dropped above the 1728px-tall logical band.
  top = 450;
  # DP-2's offset below DP-3's top edge, in logical pixels.
  leftY = 169;
in
runCommand "busan-wallpaper" { nativeBuildInputs = [ imagemagick ]; } ''
  mkdir -p $out
  magick ${../wallpapers/busan.jpg} -auto-orient -resize ${toString width}x scaled.png
  magick scaled.png -crop 2560x1440+${toString x0}+${toString (top + leftY)} +repage $out/left.png
  magick scaled.png -crop 3072x1728+${toString (x0 + 2560)}+${toString top} +repage -resize 3840x2160! $out/right.png
''
