{ config, pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    nix-direnv.package = pkgs.lixPackageSets.stable.nix-direnv;
  };

  # for .envrc's in child directories add "source_up"
  # for them to pick up this config
  home.file."dev/work/.envrc".text = ''
    dotenv
  '';
}
