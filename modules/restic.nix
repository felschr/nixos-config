{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    systemd.services = mapAttrs' (name: backup:
      nameValuePair "restic-backups-${name}" ({
        serviceConfig = {
          CPUWeight = 25;
          MemoryHigh = "50%";
          MemoryMax = "75%";
          IOWeight = 50;
          IOSchedulingClass = "idle";
          IOSchedulingPriority = 7;
        };
      })) config.services.restic.backups;
  };
}
