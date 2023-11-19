{ config, pkgs, ... }:

let
  inherit (config.services.matrix-conduit.settings.global) server_name;
  bridge_permissions = {
    "@felschr:${server_name}" = "admin";
    "@felschr:matrix.org" = "admin";
  };
  bridge_encryption = {
    allow = true;
    default = true;
    require = true;
    appservice = true;
    allow_key_sharing = true;
    key_sharing.allow = true;
    delete_keys.delete_outdated_inbound = false;
  };
in {
  # Mautrix-signal settings
  services.signald.enable = true;
  systemd.services.matrix-as-signal = {
    requires = [ "signald.service" ];
    after = [ "signald.service" ];
    path = [
      pkgs.ffmpeg # voice messages need `ffmpeg`
    ];
  };

  services.matrix-appservices = {
    addRegistrationFiles = false;
    homeserverDomain = server_name;
    homeserverURL = "https://matrix.${server_name}";
    services = {
      signal = {
        port = 29184;
        format = "mautrix-python";
        package = pkgs.unstable.mautrix-signal;
        serviceConfig = {
          StateDirectory = [ "matrix-as-signal" ];
          SupplementaryGroups = [ "signald" ];
        };
        settings.signal = {
          socket_path = config.services.signald.socketPath;
          outgoing_attachment_dir = "/var/lib/signald/tmp";
        };
        settings.bridge.permissions = bridge_permissions;
        settings.bridge.encryption = bridge_encryption;
      };
      whatsapp = {
        port = 29183;
        format = "mautrix-go";
        package = pkgs.unstable.mautrix-whatsapp;
        settings.bridge.permissions = bridge_permissions;
        settings.bridge.encryption = bridge_encryption;
      };
    };
  };
}
