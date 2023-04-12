{ config, pkgs, ... }:

{
  imports = [
    ./bash.nix
    ./zsh.nix
    ./nushell.nix
    ./starship.nix
    ./kitty.nix
    ./direnv.nix
  ];

  programs.fzf = { enable = true; };

  home.file."dev/work/.env".text = ''
    BROWSER=mullvad-browser-work
  '';
}
