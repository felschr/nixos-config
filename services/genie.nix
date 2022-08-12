{ config, lib, pkgs, ... }:

let
  dataDir = "/var/lib/genie-server";
  port = 3232;
in {
  virtualisation.oci-containers.containers = {
    genie = {
      image = "stanfordoval/almond-server";
      ports = [ "${toString port}:3000" ];
      environment.PULSE_SERVER = "unix:/run/pulse/native";
      volumes = [
        "/dev/shm:/dev/shm"
        "/run/pulse:/run/pulse"
        "${dataDir}:/var/lib/genie-server"
      ];
    };
  };
}
