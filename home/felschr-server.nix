{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./base.nix
    ./shell
    ./editors/lsp.nix
    ./editors/helix
    ./ssh.nix
    ./git.nix
  ];

  home.packages = with pkgs; [
    fh
    ncurses
  ];

  # used as fallback if gnome-keyring does not startup
  services.ssh-agent.enable = true;
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";

  programs.zellij.enableZshIntegration = lib.mkForce false;

  programs.git.defaultProfile = "private";

  home.stateVersion = "25.05";
}
