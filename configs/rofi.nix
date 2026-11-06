{ config, lib, ... }:

let
  p = import ./palette.nix { inherit lib; };
in
{
  programs.rofi = {
    enable = true;
    theme = "${config.xdg.configHome}/rofi/shared/base.rasi";
    settings = {
      font = "JetBrainsMono Nerd Font 13";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      disable-history = false;
      sort = true;
      sorting-method = "fzf";
      display-drun = "busan";
      display-window = "go to";
      display-ssh = "ssh";
    };
  };

  xdg.configFile = {
    "rofi/shared/colors.rasi".text = ''
      * {
          bg:        ${p.hex p.void};
          bg-alt:    ${p.hex p.surface0};
          surface:   ${p.hex p.surface1};
          text:      ${p.hex p.text};
          text-dim:  ${p.hex p.muted};
          accent:    ${p.hex p.roof};
          alert:     ${p.hex p.brick};
          warm:      ${p.hex p.haze};
          teal:      ${p.hex p.teal};

          background-color: transparent;
          text-color:       @text;
      }
    '';

    "rofi/shared/base.rasi".text = ''
      @import "colors.rasi"

      * {
          font: "JetBrainsMono Nerd Font 13";
      }

      window {
          background-color: @bg;
          border:           2px solid;
          border-color:     @accent;
          border-radius:    14px;
          width:            560px;
          padding:          0px;
      }

      mainbox {
          background-color: transparent;
          padding:          14px;
          spacing:          12px;
          children:         [ inputbar, listview ];
      }

      inputbar {
          background-color: @surface;
          text-color:       @text;
          border-radius:    10px;
          padding:          10px 14px;
          spacing:          10px;
          children:         [ prompt, entry ];
      }

      prompt {
          background-color: transparent;
          text-color:       @accent;
          font:             "JetBrainsMono Nerd Font Bold 13";
      }

      entry {
          background-color:  transparent;
          text-color:        @text;
          placeholder:       "search…";
          placeholder-color: @text-dim;
          cursor:            text;
      }

      listview {
          background-color: transparent;
          columns:          1;
          lines:            8;
          spacing:          4px;
          cycle:            true;
          dynamic:          true;
          scrollbar:        false;
          fixed-height:     false;
      }

      element {
          background-color: transparent;
          text-color:       @text;
          border-radius:    8px;
          padding:          8px 12px;
          spacing:          12px;
      }

      element normal normal    { text-color: @text;  }
      element normal active    { text-color: @warm;  }
      element normal urgent    { text-color: @alert; }
      element alternate normal { text-color: @text;  }
      element alternate active { text-color: @warm;  }
      element alternate urgent { text-color: @alert; }

      element selected normal { background-color: @accent; text-color: @bg; }
      element selected active { background-color: @accent; text-color: @bg; }
      element selected urgent { background-color: @alert;  text-color: @bg; }

      element-icon {
          background-color: transparent;
          size:             1.1em;
          vertical-align:   0.5;
      }

      element-text {
          background-color: transparent;
          text-color:       inherit;
          vertical-align:   0.5;
      }

      message {
          background-color: @surface;
          border-radius:    10px;
          padding:          8px 12px;
      }

      textbox {
          background-color: transparent;
          text-color:       @text-dim;
      }
    '';

    # Two-column launcher on a translucent field, separate from the shared chrome.
    "rofi/launcher.rasi".text = ''
      configuration {
          drun-display-format: "{name}";
      }

      * {
          font:       "JetBrainsMono Nerd Font 13";
          bg:         ${p.hexA p.void "c7"};
          input-bg:   ${p.hexA p.surface0 "b3"};
          accent-bd:  ${p.hexA p.roof "8c"};
          accent-sel: ${p.hexA p.roof "38"};
          teal-bd:    ${p.hexA p.teal "59"};
          fg:         ${p.hex p.text};
          fg-dim:     ${p.hex p.muted};
          background-color: transparent;
          text-color:       @fg;
      }

      window {
          width:            800px;
          location:         center;
          anchor:           center;
          background-color: @bg;
          border:           1px solid;
          border-color:     @accent-bd;
          border-radius:    20px;
          padding:          0px;
      }

      mainbox {
          background-color: transparent;
          padding:          4px;
          children:         [ inputbar, listview ];
      }

      inputbar {
          margin:           18px;
          padding:          12px 18px;
          border:           1px solid;
          border-color:     @teal-bd;
          border-radius:    14px;
          background-color: @input-bg;
          text-color:       @fg;
          spacing:          0px;
          children:         [ entry ];
      }

      entry {
          background-color:  transparent;
          text-color:        @fg;
          placeholder:       "search the city…";
          placeholder-color: @fg-dim;
          cursor:            text;
      }

      listview {
          columns:          2;
          lines:            5;
          margin:           6px 14px;
          spacing:          4px;
          scrollbar:        false;
          fixed-height:     false;
          background-color: transparent;
      }

      element {
          margin:           3px 8px;
          padding:          10px 14px;
          border:           1px solid;
          border-color:     transparent;
          border-radius:    12px;
          spacing:          14px;
          background-color: transparent;
          text-color:       @fg-dim;
      }

      element selected {
          background-color: @accent-sel;
          border-color:     @accent-bd;
          text-color:       @fg;
      }

      element-icon {
          size:             28px;
          background-color: transparent;
          vertical-align:   0.5;
      }

      element-text {
          background-color: transparent;
          text-color:       inherit;
          vertical-align:   0.5;
      }
    '';

    "rofi/windows.rasi".text = ''
      @import "shared/base.rasi"

      window {
          width:    640px;
          location: center;
          anchor:   center;
      }

      prompt       { str: "go to"; }
      listview     { columns: 1; lines: 10; }
      element-icon { size: 1.4em; }
    '';

    # Drops down from the top-right, under the bar's power button.
    "rofi/menu.rasi".text = ''
      @import "shared/base.rasi"

      window {
          width:    420px;
          location: north east;
          anchor:   north east;
          x-offset: -10px;
          y-offset: 48px;
      }

      mainbox {
          children: [ inputbar, message, listview ];
      }

      message {
          background-color: @surface;
          border-radius:    10px;
          padding:          8px 12px;
          margin:           0px 0px 4px 0px;
      }

      textbox      { background-color: transparent; text-color: @text; }
      listview     { columns: 1; lines: 10; }
      element-icon { size: 1.2em; }
    '';
  };
}
