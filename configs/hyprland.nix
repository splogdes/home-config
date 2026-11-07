{ config, pkgs, lib, ... }:

# The i3 setup on Hyprland: hy3 gives i3-style manual tiling, keybindings follow i3.
let
  p = import ./palette.nix { inherit lib; };
  wallpaper = pkgs.callPackage ../packages/busan-wallpaper.nix { };
  snap = pkgs.callPackage ../packages/snap.nix { };
  lock = "${config.programs.swaylock.package}/bin/swaylock -f -i DP-2:${wallpaper}/left.png -i DP-3:${wallpaper}/right.png";
  rgba = c: a: "rgba(${c}${a})";

  launcher = "rofi -show drun -show-icons -theme ~/.config/rofi/launcher.rasi";

  # Lua-config helpers: dispatchers are Lua expressions, so they go in as inline Lua.
  lua = lib.generators.mkLuaInline;
  str = lib.generators.toLua { };
  exec = cmd: lua "hl.dsp.exec_cmd(${str cmd})";
  hy3 = fn: args: lua "hy3.${fn}(${lib.concatMapStringsSep ", " str args})";
  bind = keys: action: { _args = [ keys action ]; };
  bindOpts = keys: action: opts: { _args = [ keys action opts ]; };
  super = keys: action: bind "SUPER + ${keys}" action;
  repeating = { locked = true; repeating = true; };
  directions = [ "left" "right" "up" "down" ];
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
    configType = "lua";
    plugins = [ pkgs.hyprlandPlugins.hy3 ];

    settings = {
      hy3._var = lua "hl.plugin.hy3";

      monitor = [
        { output = "DP-3"; mode = "3840x2160@120"; position = "2560x224"; scale = "1.25"; }
        { output = "DP-2"; mode = "2560x1440@74.92"; position = "0x393"; scale = "1"; }
      ];

      on._args = [
        "hyprland.start"
        (lua ''
          function()
            hl.exec_cmd(${str "${pkgs.swaybg}/bin/swaybg -o DP-2 -i ${wallpaper}/left.png -m fill -o DP-3 -i ${wallpaper}/right.png -m fill"})
            hl.exec_cmd("gnome-keyring-daemon --start --components=secrets,ssh")
            hl.exec_cmd(${str "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"})
          end'')
      ];

      config = {
        xwayland.force_zero_scaling = true;

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
          col = {
            active_border = rgba p.roof "ff";
            inactive_border = rgba p.surface1 "ff";
          };
          resize_on_border = true;
        };

        decoration = {
          rounding = 12;
          inactive_opacity = 0.94;
          blur = { enabled = true; size = 5; passes = 3; new_optimizations = true; };
          shadow = { enabled = true; range = 16; render_power = 3; color = "rgba(00000073)"; };
        };

        animations.enabled = true;

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
        };

        plugin.hy3.tabs = {
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

      # Rise + scale on open/close, smooth moves.
      curve = [
        { _args = [ "drift" { type = "bezier"; points = [ [ 0.16 1 ] [ 0.3 1 ] ]; } ]; }
        { _args = [ "settle" { type = "bezier"; points = [ [ 0.2 0.9 ] [ 0.4 1 ] ]; } ]; }
        { _args = [ "fadeOut" { type = "bezier"; points = [ [ 0.3 0 ] [ 0.84 0 ] ]; } ]; }
      ];
      animation = [
        { leaf = "windows"; enabled = true; speed = 4; bezier = "drift"; style = "popin 92%"; }
        { leaf = "windowsOut"; enabled = true; speed = 3; bezier = "fadeOut"; style = "popin 92%"; }
        { leaf = "windowsMove"; enabled = true; speed = 4; bezier = "drift"; }
        { leaf = "border"; enabled = true; speed = 8; bezier = "settle"; }
        { leaf = "fade"; enabled = true; speed = 4; bezier = "settle"; }
        { leaf = "workspaces"; enabled = true; speed = 5; bezier = "drift"; style = "slidefade 15%"; }
        { leaf = "layers"; enabled = true; speed = 3; bezier = "drift"; style = "fade"; }
      ];

      # i3 smart_gaps + hide_edge_borders smart: a lone tiled window fills the screen square.
      workspace_rule = map (ws: { workspace = ws; gaps_out = 0; gaps_in = 0; }) [ "w[tv1]" "f[1]" ];

      window_rule =
        map (ws: { match = { float = false; workspace = ws; }; border_size = 0; rounding = 0; }) [ "w[tv1]" "f[1]" ]
        ++ [
          # Apps (kitty among them) ask to open maximised; tiling should decide instead.
          { match.class = ".*"; suppress_event = "maximize"; }
          { match.class = "^(spotify)$"; opacity = "0.8 override 0.8 override"; }

          { match.class = "^(zen.*)$"; workspace = "2 silent"; }
          { match.class = "^(code)$"; workspace = "3 silent"; }
          { match.class = "^(steam|signal)$"; workspace = "4 silent"; }
          { match.class = "^(spotify)$"; workspace = "5 silent"; }

          { match.class = "^(org.coolercontrol.CoolerControl)$"; float = true; size = "1200 700"; center = true; }
          { match.class = "^([Ss]olaar)$"; float = true; size = "1055 600"; center = true; }
        ];

      layer_rule = { match.namespace = "rofi"; blur = true; ignore_alpha = 0; };

      bind = [
        (super "Return" (exec "kitty"))
        (super "D" (exec launcher))
        (super "SHIFT + D" (exec launcher))
        (bind "XF86Search" (exec launcher))
        (super "SHIFT + W" (exec "rofi -show window -show-icons -theme ~/.config/rofi/windows.rasi"))
        (super "SHIFT + S" (exec "rofi -show ssh"))

        (super "SHIFT + Q" (hy3 "kill_active" [ ]))
        (super "F" (lua ''hl.dsp.window.fullscreen({ action = "toggle" })''))
        (super "SHIFT + Space" (lua ''hl.dsp.window.float({ action = "toggle" })''))
        (super "Space" (hy3 "toggle_focus_layer" [ ]))
        (super "A" (hy3 "change_focus" [ "raise" ]))

        (super "H" (hy3 "make_group" [ "h" ]))
        (super "V" (hy3 "make_group" [ "v" ]))
        (super "E" (hy3 "change_group" [ "opposite" ]))
        (super "W" (hy3 "change_group" [ "toggletab" ]))
        (super "S" (hy3 "change_group" [ "toggletab" ]))

        (super "minus" (lua ''hl.dsp.workspace.toggle_special("scratchpad")''))
        (super "SHIFT + minus" (lua ''hl.dsp.window.move({ workspace = "special:scratchpad", follow = false })''))
        # Binds match the unshifted key: < and > are Shift+comma/period on a UK layout.
        (super "SHIFT + comma" (lua ''hl.dsp.workspace.move({ monitor = "l" })''))
        (super "SHIFT + period" (lua ''hl.dsp.workspace.move({ monitor = "r" })''))

        (super "SHIFT + X" (exec "loginctl lock-session"))
        (bind "XF86ScreenSaver" (exec "loginctl lock-session"))
        # The keyboard's lock key sends Super+L.
        (super "L" (exec "loginctl lock-session"))
        (super "SHIFT + P" (exec "systemctl suspend"))
        (super "SHIFT + C" (lua "hl.dsp.reload_config()"))
        (super "SHIFT + R" (lua "hl.dsp.reload_config()"))
        (super "SHIFT + E" (exec "uwsm stop"))
        (super "R" (lua ''hl.dsp.submap("resize")''))

        (bind "Print" (exec "snap area"))
        (super "Print" (exec "snap active"))

        (bindOpts "XF86AudioRaiseVolume" (exec "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 2%+") repeating)
        (bindOpts "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-") repeating)
        (bindOpts "XF86MonBrightnessUp" (exec "ddcutil setvcp 10 + 10") repeating)
        (bindOpts "XF86MonBrightnessDown" (exec "ddcutil setvcp 10 - 10") repeating)
        (bindOpts "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") { locked = true; })
        (bindOpts "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") { locked = true; })
        (bindOpts "XF86AudioPlay" (exec "playerctl play-pause") { locked = true; })
        (bindOpts "XF86AudioNext" (exec "playerctl next") { locked = true; })
        (bindOpts "XF86AudioPrev" (exec "playerctl previous") { locked = true; })
        (bind "XF86Calculator" (exec "kitty -e python3"))

        (bindOpts "SUPER + mouse:272" (lua "hl.dsp.window.drag()") { mouse = true; })
        (bindOpts "SUPER + mouse:273" (lua "hl.dsp.window.resize()") { mouse = true; })
      ]
      ++ lib.concatMap (d: [
        (super d (hy3 "move_focus" [ d ]))
        (super "SHIFT + ${d}" (hy3 "move_window" [ d ]))
      ]) directions
      ++ lib.concatMap (n: let key = toString (lib.mod n 10); in [
        (super key (lua "hl.dsp.focus({ workspace = ${toString n} })"))
        (super "SHIFT + ${key}" (hy3 "move_to_workspace" [ (toString n) ]))
      ]) (lib.range 1 10);
    };

    # i3's resize mode.
    submaps.resize.settings.bind =
      map (r: bindOpts r.key (lua "hl.dsp.window.resize({ x = ${r.x}, y = ${r.y}, relative = true })") { repeating = true; }) [
        { key = "left"; x = "-20"; y = "0"; }
        { key = "right"; x = "20"; y = "0"; }
        { key = "up"; x = "0"; y = "-20"; }
        { key = "down"; x = "0"; y = "20"; }
      ]
      ++ map (k: bind k (lua ''hl.dsp.submap("reset")'')) [ "escape" "Return" "SUPER + R" ];
  };

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
      { timeout = 720; command = "${pkgs.hyprland}/bin/hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'"; resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'"; }
    ];
  };
}
