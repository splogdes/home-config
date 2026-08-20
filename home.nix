{ inputs, pkgs, ... }:

{
  imports = [
    ./configs/hyprland.nix
    ./configs/hyprlock.nix
    ./configs/hypridle.nix
    ./configs/gtk.nix
    ./configs/kitty.nix
    ./configs/neovim.nix
    ./configs/tmux.nix
    ./configs/wofi.nix
    ./configs/waybar.nix
    ./configs/zsh.nix
    ./configs/mako.nix
    ./configs/btop.nix
    ./configs/fastfetch.nix
    ./configs/electronics.nix
    ./packages/artemis-vcs.nix
  ];

  home.username = "splogdes";
  home.homeDirectory = "/home/splogdes";
  home.stateVersion = "25.11";

  # Anything with a programs.* or services.* module below is installed by that
  # module, so it does not belong here.
  home.packages = with pkgs; [
    # --- DESKTOP SHELL ---
    hyprpaper
    hyprpolkitagent
    libnotify
    nwg-look
    # gsettings CLI, used by nwg-look and the dconf settings
    glib

    # --- SCREENSHOT & MEDIA ---
    grimblast
    swappy
    cava
    pavucontrol

    # --- APPS ---
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    vscode
    spotify
    signal-desktop
    obsidian
    # ckan is for kerbal space program mod management
    ckan

    # --- CLI ---
    fd
    ripgrep
    duf
    uv
    claude-code

    # --- SYSTEM ---
    seahorse
    gparted
    baobab
    thunar
    ddcutil
    nvidia-vaapi-driver
  ];

  services.playerctld.enable = true;

  services.blueman-applet.enable = true;

  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "splogdes";
          email = "95136830+splogdes@users.noreply.github.com";
        };
        push = {
          autoSetupRemote = true;
        };
        init = {
          defaultBranch = "main";
        };
      };
    };

    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "splogdes";
          email = "95136830+splogdes@users.noreply.github.com";
        };
        ui.default-command = "log";
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd cd"
      ];
    };

    home-manager.enable = true;
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      wallpaper = [
        {
          monitor = "";
          path = "/home/splogdes/Pictures/artimusII.jpg";
        }
      ];
      preload = [
        "/home/splogdes/Pictures/artimusII.jpg"
      ];
      splash = false;
    };
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };
}
