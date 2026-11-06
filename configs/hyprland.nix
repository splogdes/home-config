{ config, pkgs, lib, ... }:

# The i3 setup on Hyprland: hy3 gives i3-style manual tiling, keybindings follow i3.
let
  p = import ./palette.nix { inherit lib; };
  wallpaper = pkgs.callPackage ../packages/busan-wallpaper.nix { };
  snap = pkgs.callPackage ../packages/snap.nix { };
  lock = "${config.programs.swaylock.package}/bin/swaylock -f -i DP-2:${wallpaper}/left.png -i DP-3:${wallpaper}/right.png";
  rgba = c: a: "rgba(${c}${a})";

  launcher = "rofi -show drun -show-icons -theme ~/.config/rofi/launcher.rasi";
  workspaces = lib.range 1 10;
  key = n: toString (lib.mod n 10);
in
{
  home.packages = [ snap pkgs.wl-clipboard ];

  wayland.windowManager.hyprland = {
    enable = true;
    # Hyprland itself comes from the NixOS programs.hyprland module (UWSM session);
    # hy3 is built against the same nixpkgs Hyprland, so keep both flakes in step.
    package = null;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    systemd.enable = false;
    configType = "hyprlang";
    plugins = [ pkgs.hyprlandPlugins.hy3 ];

    settings = {
      "$mod" = "SUPER";

      monitor = [
        "DP-3, 3840x2160@120, 2560x224, 1.25"
        "DP-2, 2560x1440@74.92, 0x393, 1"
      ];

      xwayland.force_zero_scaling = true;

      exec-once = [
        "${pkgs.swaybg}/bin/swaybg -o DP-2 -i ${wallpaper}/left.png -m fill -o DP-3 -i ${wallpaper}/right.png -m fill"
        "gnome-keyring-daemon --start --components=secrets,ssh"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      ];

      input = {
        kb_layout = "gb";
        repeat_delay = 300;
        follow_mouse = 1;
        float_switch_override_focus = 2;
      };

      # i3: gaps inner 10 / outer 4, 2px borders.
      general = {
        layout = "hy3";
        gaps_in = 5;
        gaps_out = 14;
        border_size = 2;
        "col.active_border" = rgba p.roof "ff";
        "col.inactive_border" = rgba p.surface1 "ff";
        resize_on_border = true;
      };

      decoration = {
        rounding = 12;
        inactive_opacity = 0.94;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 16;
          render_power = 3;
          color = "rgba(00000073)";
        };
      };

      # Rise + scale on open/close, smooth moves.
      animations = {
        enabled = true;
        bezier = [
          "drift, 0.16, 1, 0.3, 1"
          "settle, 0.2, 0.9, 0.4, 1"
          "fadeOut, 0.3, 0, 0.84, 0"
        ];
        animation = [
          "windows, 1, 4, drift, popin 92%"
          "windowsOut, 1, 3, fadeOut, popin 92%"
          "windowsMove, 1, 4, drift"
          "border, 1, 8, settle"
          "fade, 1, 4, settle"
          "workspaces, 1, 5, drift, slidefade 15%"
          "layers, 1, 3, drift, fade"
        ];
      };

      plugin.hy3 = {
        tabs = {
          height = 22;
          padding = 6;
          radius = 8;
          border_width = 1;
          text_font = "JetBrainsMono Nerd Font";
          text_height = 9;
          colors = {
            active = rgba p.roof "40";
            active_border = rgba p.roof "ee";
            active_text = rgba p.bright "ff";
            focused = rgba p.surface2 "60";
            focused_border = rgba p.overlay "ee";
            focused_text = rgba p.text "ff";
            inactive = rgba p.surface0 "60";
            inactive_border = rgba p.surface1 "aa";
            inactive_text = rgba p.muted "ff";
            urgent = rgba p.brick "40";
            urgent_border = rgba p.brick "ee";
            urgent_text = rgba p.bright "ff";
          };
        };
      };

      # i3 smart_gaps + hide_edge_borders smart: a lone tiled window fills the screen square.
      workspace = [
        "w[tv1], gapsout:0, gapsin:0"
        "f[1], gapsout:0, gapsin:0"
      ];

      windowrule = [
        # Apps (kitty among them) ask to open maximised; tiling should decide instead.
        "match:class .*, suppress_event maximize"

        "match:float false, match:workspace w[tv1], border_size 0"
        "match:float false, match:workspace w[tv1], rounding 0"
        "match:float false, match:workspace f[1], border_size 0"
        "match:float false, match:workspace f[1], rounding 0"

        "match:class ^(spotify)$, opacity 0.8 override 0.8 override"

        "match:class ^(zen.*)$, workspace 2 silent"
        "match:class ^(code)$, workspace 3 silent"
        "match:class ^(steam|signal)$, workspace 4 silent"
        "match:class ^(spotify)$, workspace 5 silent"

        "match:class ^(org.coolercontrol.CoolerControl)$, float on"
        "match:class ^(org.coolercontrol.CoolerControl)$, size 1200 700"
        "match:class ^(org.coolercontrol.CoolerControl)$, center on"
        "match:class ^([Ss]olaar)$, float on"
        "match:class ^([Ss]olaar)$, size 1055 600"
        "match:class ^([Ss]olaar)$, center on"
      ];

      layerrule = [
        "match:namespace rofi, blur on"
        "match:namespace rofi, ignore_alpha 0"
      ];

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      bind = [
        "$mod, Return, exec, kitty"
        "$mod, D, exec, ${launcher}"
        "$mod SHIFT, D, exec, ${launcher}"
        ", XF86Search, exec, ${launcher}"
        "$mod SHIFT, W, exec, rofi -show window -show-icons -theme ~/.config/rofi/windows.rasi"
        "$mod SHIFT, S, exec, rofi -show ssh"

        "$mod SHIFT, Q, hy3:killactive"
        "$mod, F, fullscreen, 0"
        "$mod SHIFT, Space, togglefloating"
        "$mod, Space, hy3:togglefocuslayer"
        "$mod, A, hy3:changefocus, raise"

        "$mod, Left, hy3:movefocus, l"
        "$mod, Right, hy3:movefocus, r"
        "$mod, Up, hy3:movefocus, u"
        "$mod, Down, hy3:movefocus, d"
        "$mod SHIFT, Left, hy3:movewindow, l"
        "$mod SHIFT, Right, hy3:movewindow, r"
        "$mod SHIFT, Up, hy3:movewindow, u"
        "$mod SHIFT, Down, hy3:movewindow, d"

        "$mod, H, hy3:makegroup, h"
        "$mod, V, hy3:makegroup, v"
        "$mod, E, hy3:changegroup, opposite"
        "$mod, W, hy3:changegroup, toggletab"
        "$mod, S, hy3:changegroup, toggletab"

        "$mod, minus, togglespecialworkspace"
        "$mod SHIFT, minus, movetoworkspacesilent, special"
        # Binds match the unshifted key: < and > are Shift+comma/period on a UK layout.
        "$mod SHIFT, comma, movecurrentworkspacetomonitor, l"
        "$mod SHIFT, period, movecurrentworkspacetomonitor, r"

        "$mod SHIFT, X, exec, loginctl lock-session"
        ", XF86ScreenSaver, exec, loginctl lock-session"
        # The keyboard's lock key sends Super+L.
        "$mod, L, exec, loginctl lock-session"
        "$mod SHIFT, P, exec, systemctl suspend"
        "$mod SHIFT, C, exec, hyprctl reload"
        "$mod SHIFT, R, exec, hyprctl reload"
        "$mod SHIFT, E, exec, uwsm stop"

        ", Print, exec, snap area"
        "$mod, Print, exec, snap active"

        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86Calculator, exec, kitty -e python3"
      ]
      ++ map (n: "$mod, ${key n}, workspace, ${toString n}") workspaces
      ++ map (n: "$mod SHIFT, ${key n}, hy3:movetoworkspace, ${toString n}") workspaces;

      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 2%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
        ", XF86MonBrightnessUp, exec, ddcutil setvcp 10 + 10"
        ", XF86MonBrightnessDown, exec, ddcutil setvcp 10 - 10"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };

    # i3's resize mode.
    extraConfig = ''
      bind = $mod, R, submap, resize
      submap = resize
      binde = , Left, resizeactive, -20 0
      binde = , Right, resizeactive, 20 0
      binde = , Up, resizeactive, 0 -20
      binde = , Down, resizeactive, 0 20
      bind = , Escape, submap, reset
      bind = , Return, submap, reset
      bind = $mod, R, submap, reset
      submap = reset
    '';
  };

  # PipeWire's X11 bell module segfaults when XWayland goes away.
  xdg.configFile."pipewire/pipewire.conf.d/no-x11-bell.conf".text = ''
    context.properties = { module.x11.bell = false }
  '';

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      daemonize = true;
      ignore-empty-password = true;
      show-failed-attempts = true;
      clock = true;
      timestr = "%H:%M";
      datestr = "%a %d %b";
      font = "JetBrainsMono Nerd Font";
      font-size = 32;
      effect-blur = "9x5";
      effect-vignette = "0.4:0.8";
      fade-in = 0.2;
      indicator = true;
      indicator-radius = 110;
      indicator-thickness = 8;
      color = p.void;
      inside-color = "${p.void}99";
      inside-clear-color = "${p.void}99";
      inside-ver-color = "${p.void}99";
      inside-wrong-color = "${p.void}99";
      ring-color = p.roof;
      ring-clear-color = p.haze;
      ring-ver-color = p.teal;
      ring-wrong-color = p.brick;
      key-hl-color = p.roofBright;
      bs-hl-color = p.haze;
      line-color = "00000000";
      line-clear-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
      separator-color = "00000000";
      text-color = p.bright;
      text-clear-color = p.text;
      text-ver-color = p.text;
      text-wrong-color = p.brickBright;
    };
  };

  services.swayidle = {
    enable = true;
    events = {
      lock = lock;
      before-sleep = lock;
    };
    timeouts = [
      { timeout = 600; command = "${pkgs.systemd}/bin/loginctl lock-session"; }
      { timeout = 720; command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off"; resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on"; }
    ];
  };
}
