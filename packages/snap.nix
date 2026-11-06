# Copy-and-save screenshots: clipboard + ~/Pictures/Screenshots + notification.
{ writeShellApplication, grim, slurp, jq, wl-clipboard, libnotify, coreutils }:

writeShellApplication {
  name = "snap";
  runtimeInputs = [ grim slurp jq wl-clipboard libnotify coreutils ];
  text = ''
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/$(date +%Y-%m-%dT%H%M%S).png"
    case "''${1:-area}" in
      area)   grim -g "$(slurp)" "$file" ;;
      active) grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$file" ;;
      *)      echo "usage: snap [area|active]" >&2; exit 1 ;;
    esac
    wl-copy -t image/png < "$file"
    notify-send -i "$file" "Screenshot saved" "$file"
  '';
}
