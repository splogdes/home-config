{ pkgs, lib, ... }:
let
  powerStyle = pkgs.writeText "power-style.css" ''
    window {
      background-color: rgba(8, 9, 13, 0.85);
      border: 1px solid rgba(184, 88, 66, 0.65);
      border-radius: 14px;
      font-family: "JetBrainsMono Nerd Font", monospace;
    }

    #input {
      min-height: 0px;
      height: 0px;
      margin: 0px;
      padding: 0px;
      border: none;
      opacity: 0;
      background-color: transparent;
    }

    #inner-box {
      margin: 10px;
      background-color: transparent;
    }

    #entry {
      padding: 10px;
      margin: 2px 0px;
      color: #c8d1dc;
    }

    #entry:selected {
      background: linear-gradient(90deg, rgba(184, 88, 66, 0.22) 0%, rgba(184, 88, 66, 0.0) 100%);
      border-left: 2px solid #b85842;
      border-radius: 4px;
      color: #dbe4ec;
    }
  '';

  tempStyle = pkgs.writeText "temp-style.css" ''
    window {
      background-color: rgba(8, 9, 13, 0.85);
      border: 1px solid rgba(212, 151, 89, 0.55);
      border-radius: 14px;
      font-family: "JetBrainsMono Nerd Font", monospace;
    }
    #input { opacity: 0; }
    #inner-box { margin: 10px; background-color: transparent; }

    #entry {
      padding: 12px;
      margin: 2px 0px;
      color: #c8d1dc;
    }

    #entry:selected {
      background: linear-gradient(90deg, rgba(212, 151, 89, 0.22) 0%, rgba(212, 151, 89, 0.0) 100%);
      border-left: 2px solid #d49759;
      border-radius: 0px 4px 4px 0px;
      color: #dbe4ec;
    }
  '';

  powerMenu = pkgs.writeShellScriptBin "power-menu" ''
    options="󰐥 power off\n󰜉 reboot\n󰤄 suspend\n󰗼 logout"

    selected=$(echo -e "$options" | ${pkgs.wofi}/bin/wofi --show dmenu \
      --style ${powerStyle} \
      --width 170 --height 190 \
      --location 3 --xoffset -14 --yoffset 10 \
      --columns 1 \
      --prompt "")

    case $selected in
        "󰐥 power off") systemctl poweroff ;;
        "󰜉 reboot") systemctl reboot ;;
        "󰤄 suspend") systemctl suspend ;;
        "󰗼 logout") ${pkgs.hyprland}/bin/hyprctl dispatch exit ;;
    esac
  '';

  gpuScript = pkgs.writeShellScriptBin "gpu-info" ''
    info=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,name,power.draw,power.limit,fan.speed,clocks.current.graphics,clocks.current.memory --format=csv,noheader,nounits)

    IFS=',' read -r usage temp used total name power power_limit fan core_clock mem_clock <<< "$info"

    usage=$(echo "$usage" | xargs)
    temp=$(echo "$temp" | xargs)
    used=$(echo "$used" | xargs)
    total=$(echo "$total" | xargs)
    name=$(echo "$name" | xargs)
    power=$(echo "$power" | xargs)
    power_limit=$(echo "$power_limit" | xargs)
    fan=$(echo "$fan" | xargs)
    core_clock=$(echo "$core_clock" | xargs)
    mem_clock=$(echo "$mem_clock" | xargs)

    tooltip="<b>$name</b>\ncore: $usage% @ ''${core_clock}mhz ($temp°c)\nmem:  $used / $total mib @ ''${mem_clock}mhz\npwr:  ''${power}w / ''${power_limit}w (fan: $fan%)"

    echo "{\"text\": \"$usage\", \"tooltip\": \"$tooltip\"}"
  '';

  monitorTempMenu = pkgs.writeShellScriptBin "monitor-temp-menu" ''
    options=" warm (5000k)\n standard (6500k)\n cool (9300k)\n user mode"

    selected=$(echo -e "$options" | ${pkgs.wofi}/bin/wofi --show dmenu \
      --style ${tempStyle} \
      --width 230 --height 210 \
      --location 1 --xoffset 14 --yoffset 10 \
      --columns 1 --prompt "")

    case $selected in
        " warm (5000k)")     ddcutil setvcp 14 0x04 ;;
        " standard (6500k)") ddcutil setvcp 14 0x05 ;;
        " cool (9300k)")     ddcutil setvcp 14 0x08 ;;
        " user mode")        ddcutil setvcp 14 0x0b ;;
    esac
  '';

in
{
  systemd.user.services.waybar.Unit = {
    After = lib.mkForce [ "graphical-session.target" "pipewire.service" ];
    Wants = [ "pipewire.service" ];
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.targets = [ "graphical-session.target" ];

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        margin-top = 6;
        margin-bottom = 0;
        margin-left = 12;
        margin-right = 12;
        spacing = 0;

        modules-left = [ "custom/logo"  "custom/monitor-temp" "custom/sep" "hyprland/workspaces" "custom/sep" "mpris" ];
        modules-center = [ "clock" ];
        modules-right = [ "cava" "custom/sep" "custom/gpu-usage" "cpu" "memory" "disk" "bluetooth" "custom/sep" "custom/power" ];

        "custom/logo" = {
          format = "";
          tooltip = false;
          on-click = "wofi --show drun";
        };

        "custom/sep" = {
          format = "┃";
          tooltip = false;
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
          };
        };

        "mpris" = {
          format = "{player_icon} {dynamic}";
          format-paused = "{status_icon} <i>{dynamic}</i>";
          player-icons = {
            default = "";
            spotify = "";
            firefox = "";
          };
          status-icons = {
            paused = "";
          };
          max-length = 30;
        };

        "cava" = {
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
          actions = {
            on-click-right = "mode";
          };
          on-click = "pavucontrol";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
        };

        "custom/gpu-usage" = {
          exec = "${gpuScript}/bin/gpu-info";
          return-type = "json";
          format = "󰢮 {}%";
          on-click = "coolercontrol";
          interval = 5;
        };

        "custom/monitor-temp" = {
          format = "";
          tooltip-format = "color temperature";
          on-click = "${monitorTempMenu}/bin/monitor-temp-menu";
        };

        "cpu" = {
          format = " {usage}%";
          tooltip = true;
          on-click = "kitty -e btop";
        };

        "memory" = {
          format = " {percentage}%";
          tooltip-format = "ram: {used:0.1f}g / {total:0.1f}g";
          on-click = "kitty -e btop";
        };

        "disk" = {
          format = " {percentage_used}%";
          path = "/";
          tooltip-format = "{free} free";
          on-click = "baobab";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = {
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
        };

        "bluetooth" = {
          format = "";
          format-disabled = "󰂲";
          format-connected = "󰂱 {num_connections}";
          format-connected-battery = "󰂱 {num_connections}";
          tooltip-format = " {controller_alias}\t{controller_address} ({status})\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "󰂄 {device_battery_percentage}% \t{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "󰂄 {device_battery_percentage}% \t{device_alias}\t{device_address}";
          on-click = "blueman-manager";
        };

        "tray" = {
          spacing = 8;
        };

        "clock" = {
          interval = 60;
          format = "· {:%H:%M} ·";
          format-alt = "{:%a  %d %b %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";

          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#8fb4d4'><b>{}</b></span>";
              days = "<span color='#c8d1dc'>{}</span>";
              weeks = "<span color='#4a525e'>w{}</span>";
              today = "<span color='#d49759'><b><u>{}</u></b></span>";
            };
          };

          actions = {
            on-click-right = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        "custom/power" = {
          format = "";
          on-click = "${powerMenu}/bin/power-menu";
          tooltip = false;
        };
      };
    };

    style = ''
      * {
          border: none;
          font-family: "JetBrainsMono Nerd Font", "Symbols Nerd Font Mono", "Symbols Nerd Font";
          font-size: 13px;
          font-weight: normal;
          min-height: 0;
      }

      window#waybar {
          background-color: transparent;
      }

      /* --- UNIFIED SEGMENTED BAR --- */
      .modules-left,
      .modules-center,
      .modules-right {
          background-color: rgba(8, 9, 13, 0.55);
          border: 1px solid rgba(212, 151, 89, 0.35);
          border-radius: 14px;
          padding: 2px 10px;
          margin: 2px 4px;
          color: #c8d1dc;
      }

      /* --- MODULE DEFAULTS --- */
      #custom-logo,
      #custom-monitor-temp,
      #custom-sep,
      #workspaces,
      #mpris,
      #cava,
      #custom-gpu-usage,
      #cpu,
      #memory,
      #disk,
      #pulseaudio,
      #network,
      #bluetooth,
      #tray,
      #clock,
      #custom-power {
          padding: 0 8px;
          color: #c8d1dc;
          background: transparent;
      }

      /* --- SEGMENT DIVIDER --- */
      #custom-sep {
          color: #4a525e;
          padding: 0 8px;
          font-size: 15px;
      }

      /* --- ACCENTS --- */
      #custom-logo {
          color: #d49759;
          font-size: 16px;
          padding: 0 9px 0 2px;
      }

      #custom-monitor-temp {
          color: #8fb4d4;
          font-size: 15px;
      }

      #clock {
          color: #dbe4ec;
          font-weight: bold;
          letter-spacing: 1px;
      }

      #custom-power {
          color: #b85842;
          font-size: 16px;
          padding: 0 9px 0 2px;
      }

      /* --- WORKSPACES --- */
      #workspaces {
          padding: 0 2px;
      }

      #workspaces button {
          color: #7e8694;
          min-width: 18px;
          padding: 0 9px 0 2px;
          margin: 3px 1px;
          border-radius: 8px;
          background: transparent;
          transition: all 200ms ease;
      }

      #workspaces button.active {
          color: #d49759;
          background-color: rgba(212, 151, 89, 0.12);
      }

      #workspaces button:hover {
          background-color: rgba(143, 180, 212, 0.08);
          color: #8fb4d4;
      }

      /* --- CAVA --- */
      #cava {
          color: #6b8db0;
          font-size: 12px;
          font-family: "Symbols Nerd Font Mono";
          padding: 0 10px;
      }

      /* --- MPRIS --- */
      #mpris {
          color: #8fb4d4;
          font-style: italic;
      }

      /* --- STATUS MODULES --- */
      #cpu,
      #memory,
      #disk,
      #pulseaudio,
      #bluetooth {
          color: #8fb4d4;
      }

      #custom-gpu-usage {
          color: #d49759;
      }

      #pulseaudio.muted {
          color: #4a525e;
      }

      /* --- TRAY --- */
      #tray {
          padding: 0 6px;
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
      }

      tooltip {
          background-color: rgba(8, 9, 13, 0.95);
          border: 1px solid rgba(212, 151, 89, 0.45);
          border-radius: 10px;
      }

      tooltip label {
          color: #c8d1dc;
          padding: 4px;
      }
    '';
  };
}
