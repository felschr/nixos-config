{ config, lib, pkgs, ... }:

let
  dataDir = "/var/lib/genie-server";
  port = 3232;
  ociBackend = config.virtualisation.oci-containers.backend;
in {
  systemd.services.genie-init = {
    enable = true;
    description = "Set up paths for genie";
    before = [ "${ociBackend}-genie.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      mkdir -p ${dataDir}
    '';
  };

  virtualisation.oci-containers.containers.genie = {
    image = "stanfordoval/almond-server";
    ports = [ "${toString port}:3000" ];
    environment = {
      PULSE_SERVER = "unix:/run/pulse/native";
      THINGENGINE_HOST_BASED_AUTHENTICATION = "insecure";
    };
    volumes = [
      "/dev/shm:/dev/shm"
      "/run/user/1000/pulse:/run/pulse"
      "${dataDir}:/var/lib/genie-server"
    ];
  };

  systemd.services."${ociBackend}-genie" = {
    requires = [ "sound.target" ];
    after = [ "sound.target" ];
    before = [ "home-assistant.service" ];
  };
}
