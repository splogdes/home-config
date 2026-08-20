{ pkgs, lib, ... }:
let
  p = import ./palette.nix { inherit lib; };
in
{

  # --- FZF (Artemis palette) ---
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.sessionVariables = {
    FZF_DEFAULT_OPTS = " \
      --color=fg:${p.hex p.text},bg:${p.hex p.void},hl:${p.hex p.amber} \
      --color=fg+:${p.hex p.bright},bg+:${p.hex p.surface2},hl+:${p.hex p.amberBright} \
      --color=info:${p.hex p.blue},prompt:${p.hex p.blueBright},pointer:${p.hex p.amber} \
      --color=marker:${p.hex p.amber},spinner:${p.hex p.amber},header:${p.hex p.blue} \
      --color=border:${p.hex p.surface2} \
      --border='rounded' --padding='1' --margin='1' \
      --prompt='search ❯ ' \
      --marker='' --pointer='' \
    ";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "fzf" ];
      theme = "";
    };

    initContent = ''
      # --- Artemis prompt ---

      setopt PROMPT_SUBST

      local CL_BLUE="${p.zsh p.blueBright}"
      local CL_AMBER="${p.zsh p.amber}"
      local CL_TEXT="${p.zsh p.text}"
      local CL_DIM="${p.zsh p.dim}"
      local CL_RUST="${p.zsh p.rust}"
      local RST="%f"

      function artemis_git() {
        local ref
        ref=$(git symbolic-ref HEAD 2> /dev/null) || return
        echo " ''${CL_DIM}⎇ ''${CL_AMBER}''${ref#refs/heads/}''${RST}"
      }

      # Line 1: orbit dot + cwd + git branch
      PROMPT="''${CL_DIM}◦ ''${CL_TEXT}%~\$(artemis_git)"$'\n'
      # Line 2: amber arrow on success, rust on error
      PROMPT+="%(?.''${CL_AMBER}.''${CL_RUST})❯ ''${RST}"

      RPROMPT="''${CL_DIM}[%T]''${RST}"

      alias cls="clear"
      alias monitor="btop"
      alias list="ls -la --color=auto"
    '';
  };
}
