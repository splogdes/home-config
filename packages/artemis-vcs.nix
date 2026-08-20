{ pkgs, lib, ... }:

# Shared VCS segment for the zsh prompt and the tmux status bar. Every repo on
# this machine is colocated jj + git, so jj wins when a .jj dir is present.
#
# All jj queries pass --ignore-working-copy: a prompt must never snapshot the
# working copy as a side effect of being drawn.

let
  p = import ../configs/palette.nix { inherit lib; };

  artemis-vcs = pkgs.writeShellApplication {
    name = "artemis-vcs";
    runtimeInputs = with pkgs; [ jujutsu git ];
    text = ''
      style=plain
      dir=$PWD

      while [ $# -gt 0 ]; do
        case "$1" in
          --tmux) style=tmux ;;
          *) dir=$1 ;;
        esac
        shift
      done

      cd "$dir" 2>/dev/null || exit 0

      jj_root=$(jj root --ignore-working-copy 2>/dev/null || true)

      if [ -n "$jj_root" ]; then
        change=$(jj log --ignore-working-copy --no-graph -r @ \
          -T 'change_id.shortest(8)' 2>/dev/null || true)
        bookmark=$(jj log --ignore-working-copy --no-graph \
          -r 'heads(::@ & bookmarks())' \
          -T 'bookmarks.join(",")' 2>/dev/null | head -n1 || true)

        [ -n "$change" ] || exit 0

        if [ -n "$bookmark" ]; then
          label="⎎ $bookmark @ $change"
        else
          label="@ $change"
        fi
      else
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || true)
        if [ -z "$branch" ]; then
          branch=$(git rev-parse --short HEAD 2>/dev/null || true)
          [ -n "$branch" ] || exit 0
        fi
        label="⎇ $branch"
      fi

      if [ "$style" = tmux ]; then
        printf '#[fg=${p.hex p.surface2},bg=default]#[fg=${p.hex p.blueBright},bg=${p.hex p.surface2}]%s#[fg=${p.hex p.surface2},bg=default]' \
          " $label "
      else
        printf '%s' "$label"
      fi
    '';
  };
in
{
  home.packages = [ artemis-vcs ];
}
