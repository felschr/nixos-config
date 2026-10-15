{ lib, ... }:

{
  programs.ssh = {
    enable = true;
    # HINT disable deprecated legacy defaults; keep them explicit below
    enableDefaultConfig = false;
    settings."*" = {
      ForwardAgent = lib.mkDefault false;
      AddKeysToAgent = lib.mkDefault "no";
      Compression = lib.mkDefault false;
      ServerAliveInterval = lib.mkDefault 0;
      ServerAliveCountMax = lib.mkDefault 3;
      HashKnownHosts = lib.mkDefault false;
      UserKnownHostsFile = lib.mkDefault "~/.ssh/known_hosts";
      ControlMaster = lib.mkDefault "no";
      ControlPath = lib.mkDefault "~/.ssh/master-%r@%n:%p";
      ControlPersist = lib.mkDefault "no";
    };
  };

  services.gnome-keyring.enable = true;
}
