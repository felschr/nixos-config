{ config, pkgs, ... }:

{
  virtualisation.docker = {
    rootless = {
      enable = true;
      setSocketVariable = true;
      daemon.settings.ip = "127.0.0.1";
    };
  };
}
