{ config, lib, pkgs, ... }:

let
  dataDir = "/var/lib/genie-server";
  pulseRunDir = "/run/pulse";
  port = 3232;
  ociBackend = config.virtualisation.oci-containers.backend;
in {
  systemd.services.genie-init = {
    enable = true;
    description = "Set up paths for genie";
    before = [ "${ociBackend}-genie.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      mkdir -p ${dataDir} ${pulseRunDir}
    '';
  };

  virtualisation.oci-containers.containers = {
    genie = {
      image = "stanfordoval/almond-server";
      ports = [ "${toString port}:3000" ];
      environment.PULSE_SERVER = "unix:/run/pulse/native";
      volumes = [
        "/dev/shm:/dev/shm"
        "${pulseRunDir}:/run/pulse"
        "${dataDir}:/var/lib/genie-server"
      ];
    };
  };
}
