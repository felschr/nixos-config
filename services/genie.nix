{ config, lib, pkgs, ... }:

with lib;
let
  dataDir = "/var/lib/genie-server";
  port = 3232;
  ociBackend = config.virtualisation.oci-containers.backend;

  # enables embedded genie client which uses
  # pulseaudio for speech recognition & replies
  enableClient = false;
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
      THINGENGINE_HOST_BASED_AUTHENTICATION = "insecure";
    } // optionalAttrs enableClient {
      PULSE_SERVER = "unix:/run/pulse/native";
    };
    volumes = [ "/dev/shm:/dev/shm" "${dataDir}:/var/lib/genie-server" ]
      ++ optionals enableClient [ "/run/user/1000/pulse:/run/pulse" ];
  };

  systemd.services."${ociBackend}-genie" = {
    requires = optionals enableClient [ "sound.target" ];
    after = optionals enableClient [ "sound.target" ];
    before = [ "home-assistant.service" ];
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
