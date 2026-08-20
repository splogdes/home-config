# Artemis — lofi/space palette.
# Dusty blues, amber accents, cloud whites on deep void.
# Colours are stored bare (no leading '#') so the helpers below can render each
# consumer's format: kitty/mako/btop want hex, hyprlock wants rgb()/rgba(),
# hyprland wants its own hex-alpha rgba(), zsh wants %F{}.
{ lib }:

let
  colors = {
    void     = "08090d";
    surface0 = "0f1218";
    surface1 = "15191f";
    surface2 = "1f242e";

    overlay = "3a4250";
    dim     = "4a525e";
    dim2    = "5a6270";
    muted   = "7e8694";

    text   = "c8d1dc";
    bright = "dbe4ec";

    amber       = "d49759";
    amberBright = "f0b070";
    amberDark   = "a85b2e";

    rust       = "b85842";
    rustBright = "d27260";

    green       = "7da784";
    greenBright = "9bc7a3";

    blueDim       = "3a5b7a";
    blue          = "6b8db0";
    blueBright    = "8fb4d4";
    blueBrightest = "b3d4ec";

    violet       = "8a7aa0";
    violetBright = "a89cc4";

    # Tinted backgrounds for diff hunks — dark enough to sit under body text.
    diffAddBg    = "0d1f12";
    diffChangeBg = "1a1608";
    diffDeleteBg = "1f0a08";
    diffTextBg   = "2a1e0a";
  };

  comp = c: i: toString (lib.fromHexString (builtins.substring i 2 c));
in
colors // {
  hex  = c: "#${c}";
  hexA = c: a: "#${c}${a}";

  rgb  = c: "rgb(${comp c 0}, ${comp c 2}, ${comp c 4})";
  rgba = c: a: "rgba(${comp c 0}, ${comp c 2}, ${comp c 4}, ${a})";

  hyprRgba = c: a: "rgba(${c}${a})";

  zsh = c: "%F{#${c}}";
}
