{ pkgs, lib, ... }:

let
  p = import ./palette.nix { inherit lib; };

  powerMenu = pkgs.writeShellScript "waybar-power-menu" ''
    chosen=$(printf '%s\n' \
      $'  Lock' $'  Suspend' $'  Reboot' $'  Power off' $'  Log out' \
      | rofi -dmenu -i -p "Power" -theme ~/.config/rofi/menu.rasi)

    case "$chosen" in
      *Lock)        loginctl lock-session ;;
      *Suspend)     systemctl suspend ;;
      *Reboot)      systemctl reboot ;;
      *"Power off") systemctl poweroff ;;
      *"Log out")   uwsm stop ;;
    esac
  '';

  gpu = pkgs.writeShellScript "waybar-gpu" ''
    IFS=',' read -r usage temp used total name power limit < <(
      nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,name,power.draw,power.limit \
        --format=csv,noheader,nounits | ${pkgs.gnused}/bin/sed 's/, */,/g')
    printf '{"text": "%s", "tooltip": "<b>%s</b>\\ncore: %s%% (%s°C)\\nmem:  %s / %s MiB\\npwr:  %sW / %sW"}\n' \
      "$usage" "$name" "$usage" "$temp" "$used" "$total" "$power" "$limit"
  '';
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.main = {
      layer = "top";
      position = "top";
      height = 30;
      spacing = 0;

      modules-left = [ "custom/launcher" "custom/sep" "hyprland/workspaces" "hyprland/submap" "custom/sep" "mpris" ];
      modules-center = [ "clock" ];
      modules-right = [ "cava" "custom/sep" "custom/gpu" "cpu" "memory" "disk" "bluetooth" "custom/sep" "custom/power" ];

      "custom/launcher" = {
        format = "";
        tooltip = false;
        on-click = "rofi -show drun -show-icons -theme ~/.config/rofi/launcher.rasi";
        on-click-right = "rofi -show window -show-icons -theme ~/.config/rofi/windows.rasi";
      };

      "custom/sep" = {
        format = "┃";
        tooltip = false;
      };

      "hyprland/workspaces" = {
        format = "{icon} ";
        format-icons = {
          "1" = "";
          "2" = "";
          "3" = "";
          "4" = "";
          "5" = "";
        };
      };

      mpris = {
        format = "{player_icon} <i>{dynamic}</i>";
        format-paused = "{status_icon} <i>{dynamic}</i>";
        dynamic-order = [ "artist" "title" ];
        player-icons = { default = ""; spotify = ""; firefox = ""; zen = ""; };
        status-icons.paused = "";
        max-length = 40;
        on-click-right = "playerctl next";
        on-click-middle = "playerctl previous";
      };

      clock = {
        interval = 5;
        format = "<span color='${p.hex p.teal}'>󰃭</span>  {:%a %d %b  %H:%M}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "month";
          weeks-pos = "right";
          on-scroll = 1;
          format = {
            months = "<span color='${p.hex p.tealBright}'><b>{}</b></span>";
            days = "<span color='${p.hex p.text}'>{}</span>";
            weeks = "<span color='${p.hex p.dim2}'>w{}</span>";
            today = "<span color='${p.hex p.roof}'><b><u>{}</u></b></span>";
          };
        };
        actions = {
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
      };

      cava = {
        framerate = 30;
        autosens = 1;
        sensitivity = 5;
        bars = 12;
        lower_cutoff_freq = 50;
        higher_cutoff_freq = 10000;
        method = "pipewire";
        source = "auto";
        stereo = true;
        reverse = false;
        bar_delimiter = 0;
        monstercat = false;
        waves = false;
        noise_reduction = 0.77;
        input_delay = 2;
        hide_on_silence = false;
        format-icons = [ " " "▁" "▂" "▃" "▄" "▅" "▆" "▇" ];
        on-click = "pavucontrol";
        on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+";
        on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
      };

      "custom/gpu" = {
        exec = "${gpu}";
        return-type = "json";
        interval = 5;
        format = "󰢮 {}%";
        on-click = "coolercontrol";
      };

      cpu = {
        interval = 2;
        format = " {usage}%";
        on-click = "kitty -e btop";
      };

      memory = {
        interval = 2;
        format = " {percentage}%";
        tooltip-format = "{used:0.1f}G / {total:0.1f}G used";
        on-click = "kitty -e btop";
      };

      disk = {
        interval = 30;
        path = "/";
        format = " {percentage_used}%";
        tooltip-format = "{free} free of {total}";
        on-click = "baobab";
      };

      bluetooth = {
        format = "";
        format-disabled = "󰂲";
        format-off = "󰂲";
        format-connected = "󰂱 {num_connections}";
        tooltip-format = "{controller_alias}\t{controller_address}";
        tooltip-format-connected = "{controller_alias}\n\n{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}";
        tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_battery_percentage}%";
        on-click = "blueman-manager";
      };

      "custom/power" = {
        format = "";
        tooltip = false;
        on-click = "${powerMenu}";
      };
    };

    style = ''
      * {
          border: none;
          border-radius: 0;
          font-family: "JetBrainsMono Nerd Font", "Symbols Nerd Font Mono", "Font Awesome 7 Free";
          font-size: 13px;
          min-height: 0;
      }

      window#waybar {
          background-color: alpha(${p.hex p.void}, 0.95);
          color: ${p.hex p.text};
      }

      #custom-launcher, #custom-sep, #workspaces, #submap, #mpris, #clock, #cava,
      #custom-gpu, #cpu, #memory, #disk, #bluetooth, #custom-power {
          padding: 0 8px;
      }

      #custom-launcher { color: ${p.hex p.roof}; font-size: 16px; padding-left: 14px; }
      #custom-sep      { color: ${p.hex p.surface2}; padding: 0 4px; }
      #custom-power    { color: ${p.hex p.brick}; font-size: 15px; padding-right: 16px; }

      #workspaces { padding: 0 2px; }
      #workspaces button {
          color: ${p.hex p.dim2};
          background: transparent;
          padding: 0 10px;
          border-bottom: 2px solid transparent;
      }
      #workspaces button.visible { color: ${p.hex p.text}; }
      #workspaces button.active {
          color: ${p.hex p.roof};
          border-bottom: 2px solid ${p.hex p.roof};
      }
      #workspaces button.urgent { color: ${p.hex p.haze}; }
      #workspaces button:hover  { background: alpha(${p.hex p.tealBright}, 0.08); box-shadow: none; }

      #submap {
          color: ${p.hex p.void};
          background-color: ${p.hex p.haze};
      }

      #mpris  { color: ${p.hex p.tealBright}; }
      #clock  { color: ${p.hex p.text}; }
      #cava   { color: ${p.hex p.teal}; font-family: "Symbols Nerd Font Mono"; font-size: 12px; padding: 0 10px; }
      #custom-gpu { color: ${p.hex p.roof}; }
      #cpu, #memory, #disk, #bluetooth { color: ${p.hex p.tealBright}; }

      tooltip {
          background-color: alpha(${p.hex p.void}, 0.95);
          border: 1px solid alpha(${p.hex p.roof}, 0.45);
          border-radius: 10px;
      }
      tooltip label { color: ${p.hex p.text}; padding: 4px; }
    '';
  };
}
