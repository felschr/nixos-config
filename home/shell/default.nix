{ config, pkgs, ... }:

{
  imports = [
    ./bash.nix
    ./zsh.nix
    ./nushell.nix
    ./starship.nix
    ./zellij.nix
    ./zoxide.nix
    ./eza.nix
    ./kitty.nix
    ./direnv.nix
  ];

  programs.fzf = {
    enable = true;
  };

  home.sessionVariables.GITHUB_TOKEN = "$(gh auth token 2>/dev/null)";

  home.file."dev/work/.env".text = ''
    BROWSER=mullvad-browser-work
  '';
}
