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
        show_labs_settings = true;
      };
    };
  };
}
