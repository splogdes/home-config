# Busan — Gamcheon palette.
# Blue roofs, mint walls and terracotta over a slate-teal dusk, drawn from
# ~/Pictures/busan.jpg.
# Colours are stored bare (no leading '#') so the helpers below can render each
# consumer's format: most want hex, zsh wants %F{}.
{ lib }:

let
  colors = {
    void     = "0c1419";
    surface0 = "111c23";
    surface1 = "16242c";
    surface2 = "1f303a";

    overlay = "324c5c";
    dim     = "52616c";
    dim2    = "647d92";
    muted   = "8a9aa8";

    text   = "d6e0e7";
    bright = "eef3f6";

    roofDark   = "2f6294";
    roof       = "4c8fc4";
    roofBright = "74b3e0";

    tealDim       = "2f5a5e";
    teal          = "6a9baf";
    tealBright    = "74b3c4";
    tealBrightest = "a3d8d6";

    brick       = "c4674a";
    brickBright = "de8a6c";

    forest       = "6f9a6a";
    forestBright = "93bd8c";

    haze       = "d9b48f";
    hazeBright = "ecd2b0";

    dusk       = "8f88b0";
    duskBright = "aba5cc";

    # Tinted backgrounds for diff hunks — dark enough to sit under body text.
    diffAddBg    = "0e2019";
    diffChangeBg = "1d1c14";
    diffDeleteBg = "24130f";
    diffTextBg   = "2e2618";
  };
in
colors // {
  hex  = c: "#${c}";
  hexA = c: a: "#${c}${a}";

  zsh = c: "%F{#${c}}";
}
