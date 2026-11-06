{ lib, ... }:

let p = import ./palette.nix { inherit lib; }; in
{
  programs.kitty = {
    enable = true;
    settings = {
      # --- TYPOGRAPHY ---
      font_family = "JetBrainsMono Nerd Font";
      font_size = "12.5";
      disable_ligatures = "never";

      # --- BACKGROUND ---
      background = p.hex p.void;
      background_opacity = "0.85";

      # --- FOREGROUND ---
      foreground = p.hex p.text;

      # --- WINDOW ---
      window_border_width = "0pt";
      window_padding_width = 16;
      hide_window_decorations = "yes";

      # --- CURSOR ---
      cursor = p.hex p.roof;
      cursor_text_color = p.hex p.void;
      cursor_shape = "beam";
      cursor_beam_thickness = "1.5";
      cursor_blink_interval = "0";

      # --- TAB BAR ---
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      active_tab_foreground = p.hex p.void;
      active_tab_background = p.hex p.roof;
      active_tab_font_style = "bold";
      inactive_tab_foreground = p.hex p.muted;
      inactive_tab_background = p.hex p.surface0;

      # --- BUSAN PALETTE ---

      # Black: void / mute
      color0  = p.hex p.surface1;
      color8  = p.hex p.overlay;

      # Red: terracotta brick
      color1  = p.hex p.brick;
      color9  = p.hex p.brickBright;

      # Green: hillside forest
      color2  = p.hex p.forest;
      color10 = p.hex p.forestBright;

      # Yellow: horizon haze
      color3  = p.hex p.haze;
      color11 = p.hex p.hazeBright;

      # Blue: Gamcheon roofs
      color4  = p.hex p.roof;
      color12 = p.hex p.roofBright;

      # Magenta: dusk
      color5  = p.hex p.dusk;
      color13 = p.hex p.duskBright;

      # Cyan: mint walls
      color6  = p.hex p.tealBright;
      color14 = p.hex p.tealBrightest;

      # White: text / cloud
      color7  = p.hex p.text;
      color15 = p.hex p.bright;

      # --- UX EXTRAS ---
      selection_foreground = p.hex p.void;
      selection_background = p.hex p.roof;
      url_color = p.hex p.tealBright;
      url_style = "single";
    };
  };
}
