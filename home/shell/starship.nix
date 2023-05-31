{ config, pkgs, ... }:

{
  # starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      status.disabled = false;
      status.symbol = "❌ ";
      aws.disabled = true;
      gcloud.disabled = true;

      # kitty/neovim don't play well with multi-width emojis
      nix_shell.symbol = " ";
    };
    enableNushellIntegration = true;
  };
}
