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

  # headless: gnome-keyring won't load keys, so point ssh at the non-default
  # named keys and cache passphrase-protected keys when first used
  programs.ssh.settings."*" = {
    AddKeysToAgent = "yes";
    IdentityFile = [ "~/.ssh/private_auth" ];
  };

  # shell integration is off → exitShellOnExit would be ignored (hm warning)
  programs.zellij.enableZshIntegration = lib.mkForce false;
  programs.zellij.exitShellOnExit = lib.mkForce false;

  programs.git.defaultProfile = "private";

  home.stateVersion = "25.05";
}
