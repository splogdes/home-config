{ pkgs, lib, ... }:
let
  p = import ./palette.nix { inherit lib; };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    systemd.enable = false;
    configType = "hyprlang";
  
    settings = {

      "$mod" = "SUPER";

      # --- INPUT ---
      input = {
        kb_layout = "gb";
        repeat_delay = 300;
        follow_mouse = 1; 
        float_switch_override_focus = 2;
        sensitivity = 0;
        touchpad.natural_scroll = true;
      };

      # --- MONITOR ---
      monitor = [
        "DP-3, 3840x2160@120, 2560x224, 1.25"
        "DP-2, 2560x1440@74.92,0x393, 1"
      ];

      # --- ENV ---
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "WLR_NO_HARDWARE_CURSORS,1"
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "XDG_SCREENSHOTS_DIR,/home/splogdes/Pictures/Screenshots"
      ];

      # --- STARTUP ---
      exec-once = [
        "gnome-keyring-daemon --start --components=secrets,ssh"
        "systemctl --user start hyprpolkitagent"
        "nm-applet --indicator" 
      ];

      # --- GENERAL ---
      general = {
        layout = "dwindle";

        gaps_in = 8;
        gaps_out = 16;
        border_size = 1;

        "col.active_border" = p.hyprRgba p.amber "bb";
        "col.inactive_border" = p.hyprRgba p.surface0 "aa";

        resize_on_border = true;
      };

      # --- DECORATION ---
      decoration = {
        rounding = 14;

        active_opacity = 1.0;
        inactive_opacity = 0.9;

        blur = {
          enabled = true;
          size = 9;
          passes = 3;
          ignore_opacity = false;
          new_optimizations = true;
          xray = true;
        };

        shadow = {
          enabled = true;
          range = 28;
          render_power = 4;
          color = "rgba(00000080)";
          color_inactive = "rgba(00000040)";
        };
      };

      layerrule = [
        "match:namespace waybar, animation slide top"
        "match:namespace waybar, blur on"
        "match:namespace waybar, ignore_alpha 0"
      ];

      # --- ANIMATIONS (Calm, eased decel) ---
      animations = {
        enabled = true;

        bezier = [
          "drift, 0.16, 1, 0.3, 1"
          "settle, 0.2, 0.9, 0.4, 1"
          "fadeOut, 0.4, 0, 0.6, 0.2"
        ];

        animation = [
          "windows, 1, 6, drift, popin 92%"
          "windowsOut, 1, 6, fadeOut, popin 92%"
          "windowsMove, 1, 6, drift"

          "border, 1, 12, settle"

          "fade, 1, 8, settle"
          "workspaces, 1, 7, drift, slidefade 15%"
        ];
      };

      # --- LAYOUT ---
      dwindle = {
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        vrr = 1; 
      };

      # --- WINDOW RULES ---
      windowrule = [
        # Opacity Rules
        "match:class (kitty), opacity 0.85 override 0.75 override"
        "match:class (zen), opacity 1.0 override 1.0 override"
        "match:class (spotify), opacity 0.8 override 0.8 override"

        # Floating Rules
        "match:class (.blueman-manager-wrapped), float on"
        "match:class (.blueman-manager-wrapped), size 700 500"
        "match:class (.blueman-manager-wrapped), center on"

        "match:class (org.pulseaudio.pavucontrol), float on"
        "match:class (org.pulseaudio.pavucontrol), size 800 600"
        "match:class (org.pulseaudio.pavucontrol), center on"

        "match:class (nvidia-settings), float on"
        "match:class (nvidia-settings), size 800 600"
        "match:class (nvidia-settings), center on"

        "match:class (org.gnome.baobab), float on"
        "match:class (org.gnome.baobab), size 800 600"
        "match:class (org.gnome.baobab), center on"

        "match:class (org.coolercontrol.CoolerControl), float on"
        "match:class (org.coolercontrol.CoolerControl), size 1200 700"
        "match:class (org.coolercontrol.CoolerControl), center on"

        "match:class (solaar), float on"
        "match:class (solaar), size 1055 600"
        "match:class (solaar), center on"

        # Workspace Rules
        "match:class (zen), workspace 2"
        "match:class (code), workspace 3"
        "match:class (steam), workspace 4"
        "match:class (spotify), workspace 5"
      ];

      binde = [
        "$mod, l, resizeactive, 20 0"   
        "$mod, j, resizeactive, -20 0"  
        "$mod, i, resizeactive, 0 -20"  
        "$mod, k, resizeactive, 0 20"   

        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"

        ", XF86MonBrightnessUp, exec, ddcutil setvcp 10 + 10"
        ", XF86MonBrightnessDown, exec, ddcutil setvcp 10 - 10"
      ];

      bind = [
        "$mod, left,  movefocus, l" 
        "$mod, right, movefocus, r" 
        "$mod, up,    movefocus, u" 
        "$mod, down,  movefocus, d" 

        "$mod SHIFT, left,  movewindow, l" 
        "$mod SHIFT, right, movewindow, r" 
        "$mod SHIFT, up,    movewindow, u" 
        "$mod SHIFT, down,  movewindow, d" 

        "$mod SHIFT, E, exit,"
        "$mod SHIFT, R, exec, hyprctl reload"

        "$mod, D, exec, wofi --show drun" 
        "$mod, Return, exec, kitty --single-instance" 
        "$mod, Q, killactive," 
        "$mod, F, fullscreen, 0" 
        "$mod, Space, togglefloating,"
        "$mod, P, pseudo,"
        
        ", Print, exec, grimblast --notify copysave area"
        "$mod, Print, exec, grimblast --notify copysave active"

        "$mod, 1, workspace, 1" 
        "$mod, 2, workspace, 2" 
        "$mod, 3, workspace, 3" 
        "$mod, 4, workspace, 4" 
        "$mod, 5, workspace, 5" 

        "$mod SHIFT, 1, movetoworkspace, 1" 
        "$mod SHIFT, 2, movetoworkspace, 2" 
        "$mod SHIFT, 3, movetoworkspace, 3" 
        "$mod SHIFT, 4, movetoworkspace, 4" 
        "$mod SHIFT, 5, movetoworkspace, 5"

        "$mod, comma,  focusmonitor, l"
        "$mod, period, focusmonitor, r"
        "$mod SHIFT, comma,  movecurrentworkspacetomonitor, l"
        "$mod SHIFT, period, movecurrentworkspacetomonitor, r"

        "$mod, L, exec, hyprlock"

        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86Calculator, exec, kitty --single-instance -e python3"
        ", XF86ScreenSaver, exec, hyprlock"
        ", XF86Search, exec, wofi --show drun"
      ];

      bindm = [
        "$mod, mouse:272, movewindow" 
        "$mod, mouse:273, resizewindow" 
      ];
    };
  };
}
