{ config, pkgs, ... }:

let inherit (config.services.dendrite.settings.global) server_name;
in {
  services.nginx.virtualHosts."element.felschr.com" = {
    forceSSL = true;
    enableACME = true;
    root = pkgs.element-web.override {
      conf = {
        default_server_config."m.homeserver" = {
          "base_url" = "https://matrix.${server_name}";
          "server_name" = "${server_name}";
        };
        disable_guests = true;
        features = {
          feature_pinning = true;
          feature_thread = true;
          feature_video_rooms = true;
          feature_group_calls = true;
        };
        show_labs_settings = true;
        roomDirectory.servers = [ "matrix.org" "gitter.im" "libera.chat" ];
        jitsi.preferred_domain = "meet.element.io";
        element_call.url = "https://call.element.io";
      };
    };
  };
}
