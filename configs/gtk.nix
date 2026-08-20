{ pkgs, ... }:

let
  themeName = "Colloid-Orange-Dark";

  themePackage = pkgs.colloid-gtk-theme.override {
    colorVariants = [ "dark" ];
    themeVariants = [ "orange" ];
    tweaks = [ "rimless" "black" ];
  };
in
{
  # Apps that ignore the GTK settings below read this instead.
  home.sessionVariables.GTK_THEME = themeName;

  gtk = {
    enable = true;

    theme = {
      name = themeName;
      package = themePackage;
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

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };
}
