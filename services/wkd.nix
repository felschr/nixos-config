{ config, pkgs, ... }:

{
  # Direct mode
  services.caddy.virtualHosts."web.felschr.com" = {
    extraConfig = ''
      header Strict-Transport-Security "max-age=31536000; includeSubDomains"
      handle_path /.well-known/openpgpkey/* {
        rewrite * /.well-known/openpgpkey/{http.request.host}{http.request.uri.path}
        header Access-Control-Allow-Origin *
        reverse_proxy https://openpgpkey.protonmail.ch
      }
    '';
  };

  # Advanced mode
  services.caddy.virtualHosts."openpgpkey.felschr.com" = {
    extraConfig = ''
      encode zstd gzip
      header Strict-Transport-Security "max-age=31536000; includeSubDomains"
      handle /.well-known/openpgpkey/felschr.com/* {
        header Access-Control-Allow-Origin *
        reverse_proxy https://openpgpkey.protonmail.ch
      }
    '';
  };
}
