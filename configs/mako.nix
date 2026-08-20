{ pkgs, lib, ... }:

let p = import ./palette.nix { inherit lib; }; in
{
  services.mako = {
    enable = true;

    settings = {
      # --- VISUALS ---
      font = "JetBrainsMono Nerd Font 11";
      width = 380;
      height = 140;

      "background-color" = p.hexA p.surface0 "e6";
      "text-color" = p.hex p.text;

      "border-color" = p.hex p.amber;
      "border-size" = 1;
      "border-radius" = 14;

      padding = "18";
      margin = "14";

      icons = true;
      "icon-path" = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";

      # --- BEHAVIOR ---
      "default-timeout" = 5000;
      "ignore-timeout" = false;

      layer = "overlay";
    };

    extraConfig = ''
      [urgency=low]
      border-color=${p.hex p.overlay}
      text-color=${p.hex p.muted}

      [urgency=normal]
      border-color=${p.hex p.amber}

      [urgency=critical]
      border-color=${p.hex p.rust}
      text-color=${p.hex p.bright}
      default-timeout=0

      [category=mpd]
      border-color=${p.hex p.blue}
      default-timeout=2000
      group-by=category
    '';
  };
}
