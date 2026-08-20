
{ inputs, pkgs, ... }:

{
  imports = [
    ./configs/hyprland.nix
    ./configs/hyprlock.nix
    ./configs/hypridle.nix
    ./configs/kitty.nix
    ./configs/wofi.nix
    ./configs/waybar.nix
    ./configs/zsh.nix
    ./configs/mako.nix
    ./configs/btop.nix
    ./configs/fastfetch.nix
  ];

  home.username = "splogdes";
  home.homeDirectory = "/home/splogdes";
  home.stateVersion = "25.11";
  home.sessionVariables = {
    GTK_THEME = "Colloid-Orange-Dark";
  };

  home.packages = with pkgs; [
    waybar
    wofi
    hyprpaper
    mako
    libnotify
    kitty
    hyprpolkitagent
    hyprlock
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    vscode
    neovim
    spotify
    duf
    tmux
    seahorse
    fzf
    cava
    grimblast
    swappy
    pavucontrol
    bibata-cursors
    (colloid-gtk-theme.override {
      colorVariants = [ "dark" ];
      tweaks = [ "rimless" "black" ];
      themeVariants = [ "orange" ];
    })
    papirus-icon-theme
    nwg-look
    glib
    fastfetch
    playerctl
    nvidia-vaapi-driver
    signal-desktop
    baobab
    gparted
    thunar
    python3
    ddcutil
    obsidian
    claude-code
    jujutsu
    uv
    ltspice
    (symlinkJoin {
      name = "kicad-themed";
      paths = [ kicad ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/kicad --set GTK_THEME "Adwaita:dark"
      '';
    })
    (symlinkJoin {
     name = "picoscope-wrapped";
     paths = [ picoscope ];
     buildInputs = [ makeWrapper ];
     postBuild = ''
       wrapProgram $out/bin/picoscope \
         --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}:${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
     '';
    })
    # ckan is for kerbal space program mod management
    ckan
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

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd cd"
      ];
    };
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

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  gtk = {
      enable = true;
      
      theme = {
        name = "Colloid-Orange-Dark";
        package = pkgs.colloid-gtk-theme.override {
            tweaks = [ "rimless" "black" ];
            colorVariants = [ "dark" ];
            themeVariants = [ "orange" ];
        };
      };

      iconTheme = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
      
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      gtk4 = {
        extraConfig.gtk-application-prefer-dark-theme = 1;
        theme = null;
      };
    };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
    };
  };
};

programs.home-manager.enable = true;

}
