{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # --- EDA / SIMULATION ---
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

    # --- MICROCONTROLLERS & SERIAL ---
    arduino-ide
    arduino-cli
    (python3.withPackages (ps: [ ps.pyserial ]))
    tio
    i2c-tools
  ];
}
