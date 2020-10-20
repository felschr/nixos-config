{ config, pkgs, ... }:

let shellAliases = { emacs = "emacsclient -c"; };
in {
  imports = [ ./terminal.nix ];

  programs.fzf = { enable = true; };
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      status.symbol = "❌ ";
      status.disabled = false;
      aws.disabled = true;
      gcloud.disabled = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    autocd = true;
    defaultKeymap = "viins";
    history.extended = true;
    plugins = with pkgs; [
      {
        name = "first-tab-completion";
        src = lib.cleanSource ./.;
        file = "first-tab-completion.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-history-substring-search";
        src = zsh-history-substring-search;
        file =
          "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
    ];
    initExtra = with pkgs; ''
      export KEYTIMEOUT=1

      ZSH_AUTOSUGGEST_USE_ASYNC=1
      ZSH_AUTOSUGGEST_STRATEGY=(history completion)

      zmodload zsh/complist
      zstyle ':completion:*' menu select
      zstyle ':completion:*' insert-tab false
      bindkey '^I' first-tab-completion
      bindkey -M menuselect '\e' send-break
      bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete
      bindkey -M menuselect 'h' vi-backward-char
      bindkey -M menuselect 'k' vi-up-line-or-history
      bindkey -M menuselect 'l' vi-forward-char
      bindkey -M menuselect 'j' vi-down-line-or-history

      setopt HIST_FIND_NO_DUPS
      bindkey "$terminfo[kcuu1]" history-substring-search-up
      bindkey "$terminfo[kcud1]" history-substring-search-down
      bindkey -M vicmd 'k' history-substring-search-up
      bindkey -M vicmd 'j' history-substring-search-down
    '';
    inherit shellAliases;
  };

  programs.bash = {
    enable = true;
    inherit shellAliases;
  };

  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };

  home.file.".envrc".text = ''
    dotenv
  '';
}
