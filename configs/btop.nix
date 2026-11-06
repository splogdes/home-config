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
    # Busan — lofi/space theme
    # Dusty blues, roof blue accents, cloud whites on deep void

    # --- MAIN INTERFACE ---
    theme[main_bg]="${p.hex p.void}"
    theme[main_fg]="${p.hex p.text}"
    theme[title]="${p.hex p.bright}"
    theme[hi_fg]="${p.hex p.roof}"

    # --- BOX OUTLINES (dim ocean blue) ---
    theme[cpu_box]="${p.hex p.tealDim}"
    theme[mem_box]="${p.hex p.tealDim}"
    theme[net_box]="${p.hex p.tealDim}"
    theme[proc_box]="${p.hex p.tealDim}"
    theme[div_line]="${p.hex p.surface2}"

    # --- SELECTION & INACTIVE ---
    theme[selected_bg]="${p.hex p.roof}"
    theme[selected_fg]="${p.hex p.void}"
    theme[inactive_fg]="${p.hex p.dim}"
    theme[meter_bg]="${p.hex p.surface1}"

    # --- MISC TEXT ---
    theme[graph_text]="${p.hex p.tealBright}"
    theme[proc_misc]="${p.hex p.muted}"

    # --- TEMPERATURE GRADIENT (cool → hot) ---
    theme[temp_start]="${p.hex p.teal}"
    theme[temp_mid]="${p.hex p.roof}"
    theme[temp_end]="${p.hex p.brick}"

    # --- CPU GRAPH (data stream) ---
    theme[cpu_start]="${p.hex p.tealDim}"
    theme[cpu_mid]="${p.hex p.tealBright}"
    theme[cpu_end]="${p.hex p.bright}"

    # --- MEMORY & DISK METERS ---
    # Free (dim ocean)
    theme[free_start]="${p.hex p.tealDim}"
    theme[free_mid]="${p.hex p.teal}"
    theme[free_end]="${p.hex p.tealBright}"

    # Cached (muted slate)
    theme[cached_start]="${p.hex p.overlay}"
    theme[cached_mid]="${p.hex p.dim}"
    theme[cached_end]="${p.hex p.dim2}"

    # Available (glow blue)
    theme[available_start]="${p.hex p.teal}"
    theme[available_mid]="${p.hex p.tealBright}"
    theme[available_end]="${p.hex p.tealBrightest}"

    # Used (roof blue → solar)
    theme[used_start]="${p.hex p.teal}"
    theme[used_mid]="${p.hex p.roof}"
    theme[used_end]="${p.hex p.roofBright}"

    # --- NETWORK GRAPHS ---
    # Download (cool blue)
    theme[download_start]="${p.hex p.tealDim}"
    theme[download_mid]="${p.hex p.tealBright}"
    theme[download_end]="${p.hex p.bright}"

    # Upload (roof blue, direction = warmth)
    theme[upload_start]="${p.hex p.roofDark}"
    theme[upload_mid]="${p.hex p.roof}"
    theme[upload_end]="${p.hex p.roofBright}"

    # --- PROCESS BOX ---
    theme[process_start]="${p.hex p.teal}"
    theme[process_mid]="${p.hex p.tealBright}"
    theme[process_end]="${p.hex p.roof}"
  '';
}
