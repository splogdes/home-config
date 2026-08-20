{ pkgs, lib, ... }:

let p = import ./palette.nix { inherit lib; }; in
{
  programs.btop = {
    enable = true;
    package = pkgs.btop.override { cudaSupport = true; };
    settings = {
      color_theme = "artemis";
      theme_background = true;
      truecolor = true;

      presets = "cpu:0:default,mem:0:default,net:0:default,proc:0:default,gpu:0:default";
      graph_symbol = "braille";
      rounded_corners = true;
      proc_gradient = true;
      proc_colors = true;

      update_ms = 1000;

      shown_boxes = "cpu mem net proc gpu0";
    };
  };

  xdg.configFile."btop/themes/artemis.theme".text = ''
    # Artemis — lofi/space theme
    # Dusty blues, amber accents, cloud whites on deep void

    # --- MAIN INTERFACE ---
    theme[main_bg]="${p.hex p.void}"
    theme[main_fg]="${p.hex p.text}"
    theme[title]="${p.hex p.bright}"
    theme[hi_fg]="${p.hex p.amber}"

    # --- BOX OUTLINES (dim ocean blue) ---
    theme[cpu_box]="${p.hex p.blueDim}"
    theme[mem_box]="${p.hex p.blueDim}"
    theme[net_box]="${p.hex p.blueDim}"
    theme[proc_box]="${p.hex p.blueDim}"
    theme[div_line]="${p.hex p.surface2}"

    # --- SELECTION & INACTIVE ---
    theme[selected_bg]="${p.hex p.amber}"
    theme[selected_fg]="${p.hex p.void}"
    theme[inactive_fg]="${p.hex p.dim}"
    theme[meter_bg]="${p.hex p.surface1}"

    # --- MISC TEXT ---
    theme[graph_text]="${p.hex p.blueBright}"
    theme[proc_misc]="${p.hex p.muted}"

    # --- TEMPERATURE GRADIENT (cool → hot) ---
    theme[temp_start]="${p.hex p.blue}"
    theme[temp_mid]="${p.hex p.amber}"
    theme[temp_end]="${p.hex p.rust}"

    # --- CPU GRAPH (data stream) ---
    theme[cpu_start]="${p.hex p.blueDim}"
    theme[cpu_mid]="${p.hex p.blueBright}"
    theme[cpu_end]="${p.hex p.bright}"

    # --- MEMORY & DISK METERS ---
    # Free (dim ocean)
    theme[free_start]="${p.hex p.blueDim}"
    theme[free_mid]="${p.hex p.blue}"
    theme[free_end]="${p.hex p.blueBright}"

    # Cached (muted slate)
    theme[cached_start]="${p.hex p.overlay}"
    theme[cached_mid]="${p.hex p.dim}"
    theme[cached_end]="${p.hex p.dim2}"

    # Available (glow blue)
    theme[available_start]="${p.hex p.blue}"
    theme[available_mid]="${p.hex p.blueBright}"
    theme[available_end]="${p.hex p.blueBrightest}"

    # Used (amber → solar)
    theme[used_start]="${p.hex p.blue}"
    theme[used_mid]="${p.hex p.amber}"
    theme[used_end]="${p.hex p.amberBright}"

    # --- NETWORK GRAPHS ---
    # Download (cool blue)
    theme[download_start]="${p.hex p.blueDim}"
    theme[download_mid]="${p.hex p.blueBright}"
    theme[download_end]="${p.hex p.bright}"

    # Upload (amber, direction = warmth)
    theme[upload_start]="${p.hex p.amberDark}"
    theme[upload_mid]="${p.hex p.amber}"
    theme[upload_end]="${p.hex p.amberBright}"

    # --- PROCESS BOX ---
    theme[process_start]="${p.hex p.blue}"
    theme[process_mid]="${p.hex p.blueBright}"
    theme[process_end]="${p.hex p.amber}"
  '';
}
