{ config, lib, pkgs, ... }:

# watchtower keeps images & containers up-to-date
{
  virtualisation.oci-containers.containers = {
    watchtower = {
      image = "containrrr/watchtower";
      volumes = [
        "/var/run/podman/podman.sock:/var/run/docker.sock"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        WATCHTOWER_CLEANUP = "true";
        WATCHTOWER_INCLUDE_RESTARTING = "true";
      };
    };
  };
}
