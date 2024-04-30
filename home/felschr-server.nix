{ config, pkgs, lib, ... }:

{
  imports = [ ./shell ./editors/lsp.nix ./editors/helix ./git.nix ];

  home.packages = with pkgs; [ fh ncurses ];

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
  programs.zsh.initExtra = ''
    export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh
  '';

  programs.zellij.enableZshIntegration = lib.mkForce false;

  programs.ssh.enable = true;

  programs.git.defaultProfile = "private";

  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';

  home.stateVersion = "23.05";
}
