{ config, pkgs, ... }:

{
  imports = [
    ./shell
    # ./editors
    ./git.nix
  ];

  home.packages = with pkgs; [ ncurses ];

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    # use auth subkey's keygrip: gpg2 -K --with-keygrip
    sshKeys = [ "3C48489F3B0FBB44E72180D4B1D7541C201C9987" ];
    defaultCacheTtl = 600;
    defaultCacheTtlSsh = 600;
    pinentryFlavor = "curses";
  };
  # https://github.com/nix-community/home-manager/issues/667#issuecomment-902236379
  # https://github.com/nix-community/home-manager/pull/2253
  home.sessionVariables.SSH_AUTH_SOCK =
    "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";

  programs.git.defaultProfile = "private";

  home.sessionVariables = with pkgs; { EDITOR = "nvim"; };
  programs.neovim.enable = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;

  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';

  home.stateVersion = "21.11";
}
