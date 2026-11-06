{ pkgs, lib, ... }:

let p = import ./palette.nix { inherit lib; }; in
{
  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    settings = {
      global = {
        follow = "mouse";
        font = "JetBrainsMono Nerd Font 11";
        width = 380;
        offset = "14x14";
        corner_radius = 14;
        padding = 16;
        horizontal_padding = 16;
        frame_width = 1;
        separator_height = 2;
        separator_color = "frame";
        icon_position = "left";
        max_icon_size = 64;
        word_wrap = true;
        max_lines = 5;
        background = p.hexA p.surface0 "e6";
        foreground = p.hex p.text;
        highlight = p.hex p.haze;
        mouse_left_click = "do_action";
        mouse_middle_click = "close_all";
        mouse_right_click = "close";
      };

      urgency_low = {
        frame_color = p.hex p.overlay;
        foreground = p.hex p.muted;
        timeout = 5;
      };

      urgency_normal = {
        frame_color = p.hex p.roof;
        timeout = 5;
      };

      urgency_critical = {
        frame_color = p.hex p.brick;
        foreground = p.hex p.bright;
        timeout = 0;
      };
    };
  };
}
