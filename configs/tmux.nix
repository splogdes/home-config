{ pkgs, lib, ... }:

let
  p = import ./palette.nix { inherit lib; };
  continuum = pkgs.tmuxPlugins.continuum;
in
{
  programs.tmux = {
    enable = true;
    prefix = "C-b";
    baseIndex = 1;
    mouse = true;
    keyMode = "vi";
    escapeTime = 10;
    historyLimit = 50000;
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank

      {
        plugin = tmux-floax;
        extraConfig = ''
          set -g @floax-bind '-n M-f'
          set -g @floax-width '80%'
          set -g @floax-height '80%'
          set -g @floax-border-color '${p.hex p.amber}'
          set -g @floax-text-color '${p.hex p.text}'
          set -g @floax-title 'scratch'
          set -g @floax-change-path 'true'

          # floax.tmux sources utils.sh, which reads these before setting them.
          # Seed them here so the first load doesn't spew "unknown variable".
          set-environment -g FLOAX_WIDTH '80%'
          set-environment -g FLOAX_HEIGHT '80%'
          set-environment -g FLOAX_BORDER_COLOR '${p.hex p.amber}'
          set-environment -g FLOAX_TEXT_COLOR '${p.hex p.text}'
          set-environment -g FLOAX_TITLE 'scratch'
          set-environment -g FLOAX_CHANGE_PATH 'true'
        '';
      }

      {
        plugin = tmux-sessionx;
        extraConfig = ''
          set -g @sessionx-bind 'o'
          set -g @sessionx-zoxide-mode 'on'
          set -g @sessionx-filter-current 'false'
          set -g @sessionx-preview-enabled 'true'
          set -g @sessionx-preview-location 'right'
          set -g @sessionx-preview-ratio '55%'
          set -g @sessionx-window-height '75%'
          set -g @sessionx-window-width '80%'
          set -g @sessionx-prompt 'session ❯ '
          set -g @sessionx-pointer '❯'
        '';
      }

      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
    ];

    extraConfig = ''
      # Colours come from ../configs/palette.nix.

      # --- Terminal capabilities ---
      set -ga terminal-features ",xterm-kitty:RGB,*256col*:RGB"
      set -ga terminal-overrides ",*256col*:Tc,xterm-kitty:Tc"
      # Let kitty's graphics protocol and OSC sequences through tmux.
      set -g allow-passthrough on
      set -g focus-events on
      set -g set-clipboard on

      set -g renumber-windows on
      set -g set-titles on
      set -g set-titles-string "#S ❯ #W"
      set -g display-time 2000
      set -g display-panes-time 2000
      set -g status-interval 5
      setw -g pane-base-index 1

      # --- Keybindings ---
      bind C-b send-prefix
      bind r source-file ~/.config/tmux/tmux.conf \; display "config reloaded"

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      bind -r "<" swap-window -d -t -1
      bind -r ">" swap-window -d -t +1
      bind Space next-layout
      bind e setw synchronize-panes \; display "sync #{?pane_synchronized,on,off}"
      bind X kill-session

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      # --- Chrome ---
      # Rounded chips on the terminal background, mirroring kitty's tab bar.
      set -g status-position top
      set -g status-justify left
      set -g status-style "fg=${p.hex p.muted},bg=default"
      set -g status-left-length 40
      set -g status-right-length 120

      set -g status-left "#[fg=${p.hex p.surface2},bg=default]#[fg=${p.hex p.amber},bg=${p.hex p.surface2},bold] #S #[fg=${p.hex p.surface2},bg=default,nobold] "

      set -g status-right "#(${continuum}/share/tmux-plugins/continuum/scripts/continuum_save.sh)#{?client_prefix,#[fg=${p.hex p.rust}]#[fg=${p.hex p.void}#,bg=${p.hex p.rust}#,bold] PREFIX #[fg=${p.hex p.rust}#,bg=default#,nobold],#(artemis-vcs --tmux '#{pane_current_path}')} #[fg=${p.hex p.surface2}]#[fg=${p.hex p.muted},bg=${p.hex p.surface2}] #h #[fg=${p.hex p.surface2},bg=default] #[fg=${p.hex p.blue}]#[fg=${p.hex p.void},bg=${p.hex p.blue},bold] %H:%M #[fg=${p.hex p.blue},bg=default,nobold]"

      setw -g window-status-format "#[fg=${p.hex p.surface1},bg=default]#[fg=${p.hex p.muted},bg=${p.hex p.surface1}] #I #W#{?window_zoomed_flag, ,} #[fg=${p.hex p.surface1},bg=default]"
      setw -g window-status-current-format "#[fg=${p.hex p.amberBright},bg=default]#[fg=${p.hex p.void},bg=${p.hex p.amberBright},bold] #I #W#{?window_zoomed_flag, ,} #[fg=${p.hex p.amberBright},bg=default,nobold]"
      setw -g window-status-separator " "
      setw -g window-status-activity-style "fg=${p.hex p.void},bg=${p.hex p.green}"
      setw -g window-status-bell-style "fg=${p.hex p.void},bg=${p.hex p.rust},bold"

      set -g pane-border-style "fg=${p.hex p.surface2}"
      set -g pane-active-border-style "fg=${p.hex p.amber}"
      # tmux has no rounded pane borders; single is the thinnest, least chunky
      # match for the rounded chrome everywhere else.
      set -g pane-border-lines single
      set -g pane-scrollbars modal
      set -g pane-scrollbars-style "bg=${p.hex p.surface1},fg=${p.hex p.dim}"

      set -g message-style "fg=${p.hex p.void},bg=${p.hex p.amber},bold"
      set -g message-command-style "fg=${p.hex p.text},bg=${p.hex p.surface1}"

      set -g mode-style "fg=${p.hex p.void},bg=${p.hex p.amber}"
      set -g copy-mode-match-style "fg=${p.hex p.void},bg=${p.hex p.blueBright}"
      set -g copy-mode-current-match-style "fg=${p.hex p.void},bg=${p.hex p.amberBright}"
      set -g copy-mode-mark-style "fg=${p.hex p.void},bg=${p.hex p.violet}"

      set -g display-panes-colour "${p.hex p.dim}"
      set -g display-panes-active-colour "${p.hex p.amber}"
      set -g clock-mode-colour "${p.hex p.amber}"
      set -g clock-mode-style 24

      set -g popup-border-style "fg=${p.hex p.amber}"
      set -g popup-border-lines rounded
      set -g popup-style "fg=${p.hex p.text},bg=${p.hex p.surface0}"

      set -g menu-style "fg=${p.hex p.text},bg=${p.hex p.surface0}"
      set -g menu-border-style "fg=${p.hex p.amber}"
      set -g menu-border-lines rounded
      set -g menu-selected-style "fg=${p.hex p.void},bg=${p.hex p.amber},bold"

      # sessionx renders through fzf; keep its popup on-palette too.
      set -g @sessionx-additional-options "--color=fg:${p.hex p.text},bg:${p.hex p.surface0},hl:${p.hex p.amber} --color=fg+:${p.hex p.bright},bg+:${p.hex p.surface2},hl+:${p.hex p.amberBright} --color=info:${p.hex p.blue},prompt:${p.hex p.blueBright},pointer:${p.hex p.amber} --color=marker:${p.hex p.amber},spinner:${p.hex p.amber},header:${p.hex p.blue} --color=border:${p.hex p.surface2} --border=rounded"

      # Continuum drives its save timer from a #(continuum_save.sh) job in
      # status-right. It only injects that itself when it believes no other
      # server is running, and any later status-right write would drop it, so
      # status-right carries the job directly and continuum loads afterwards.
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '10'
      run-shell ${continuum}/share/tmux-plugins/continuum/continuum.tmux
    '';
  };
}
