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
        # some containers take really long to shut down
        WATCHTOWER_TIMEOUT = "120s";
        WATCHTOWER_CLEANUP = "true";
        WATCHTOWER_INCLUDE_STOPPED = "true";
      };
    };
  };
}
