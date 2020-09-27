{ config, pkgs, ... }:

{
  imports = [
    ./shell
    # ./editors
    ./git.nix
  ];

  home.packages = with pkgs; [ ncurses ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [ "4AE1DDE05F4BB6C8E220501F1336A98E89836D90" ];
    defaultCacheTtl = 600;
    defaultCacheTtlSsh = 600;
    pinentryFlavor = "curses";
  };

  programs.gpg.enable = true;

  programs.git.defaultProfile = "private";

  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';

  home.stateVersion = "20.09";
}
