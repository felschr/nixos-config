{ config, pkgs, ... }:

let
  shellAliases = {
    emacs = "emacsclient -c";
  };
in
{
  programs.fzf = {
    enable = true;
  };
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      line_break = {
        disabled = true;
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    autocd = true;
    defaultKeymap = "viins";
    initExtraBeforeCompInit = with pkgs; ''
      source ${zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      source ${zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
    '';
    initExtra = ''
      zstyle ':completion:*' menu select
      setopt histignoredups
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey -M vicmd 'k' history-substring-search-up
      bindkey -M vicmd 'j' history-substring-search-down
    '';
    history.extended = true;
    inherit shellAliases;
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      fish_vi_key_bindings
    '';
    inherit shellAliases;
  };

  programs.bash = {
    enable = true;
    inherit shellAliases;
  };

  programs.direnv = {
    enable = true;
    stdlib = builtins.readFile ./.direnvrc;
  };

  home.file.".envrc".text = ''
    dotenv
  '';
} 
