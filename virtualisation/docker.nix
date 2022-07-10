{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    extraOptions = "--ip 127.0.0.1";
    autoPrune = {
      enable = true;
      dates = "10:00";
    };
  };
}
