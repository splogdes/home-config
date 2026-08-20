{ pkgs, lib, ... }:

let
  p = import ./palette.nix { inherit lib; };
in
{
  programs.hyprlock = {
    enable = true;

    settings = {
      # --- GENERAL ---
      general = {
        no_fade_in = false;
        grace = 0;
        disable_loading_bar = true;
        hide_cursor = true;
      };

      # --- BACKGROUND (frosted screenshot) ---
      background = [
        {
          path = "screenshot";
          blur_passes = 4;
          blur_size = 7;
          noise = 0.0117;
          contrast = 0.85;
          brightness = 0.65;
          vibrancy = 0.15;
          vibrancy_darkness = 0.1;
        }
      ];

      # --- INPUT FIELD ---
      input-field = [
        {
          size = "320, 56";
          position = "0, -130";
          monitor = "";

          dots_size = 0.25;
          dots_spacing = 0.2;
          dots_center = true;
          dots_rounding = -1;

          outer_color = p.rgba p.amber "0.55";
          inner_color = p.rgba p.void "0.7";
          font_color = p.rgb p.bright;

          fade_on_empty = false;
          placeholder_text = "<i>access code</i>";
          hide_input = false;

          rounding = 28;

          check_color = p.rgb p.blueBright;
          fail_color = p.rgb p.rust;
          fail_text = "<i>denied</i>";
        }
      ];

      # --- LABELS ---
      label = [
        # Time
        {
          text = "$TIME";
          color = p.rgba p.bright "1.0";
          font_size = 110;
          font_family = "JetBrainsMono Nerd Font";

          position = "0, 110";
          halign = "center";
          valign = "center";

          shadow_passes = 3;
          shadow_size = 8;
          shadow_color = p.rgba p.amber "0.35";
        }

        # Date
        {
          text = "cmd[update:1000] echo \"$(date +'%A · %d %B' | tr '[:upper:]' '[:lower:]')\"";
          color = p.rgba p.muted "1.0";
          font_size = 14;
          font_family = "JetBrainsMono Nerd Font";

          position = "0, 30";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
