{ config, lib, ... }:

let
  cfg = config.services.nginx-authelia;
  vhostOptionsAuth =
    { config, ... }:
    {
      options = {
        enableAutheliaAuth = lib.mkEnableOption "Enable authelia auth";
      };
      config = lib.mkIf config.enableAutheliaAuth {
        locations."/authelia".extraConfig = ''
          set $upstream_authelia http://${cfg.host}:${toString cfg.port}/api/verify;

          ## Essential Proxy Configuration
          internal;
          proxy_pass $upstream_authelia;

          ## Headers
          ## The headers starting with X-* are required.
          proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
          proxy_set_header X-Original-Method $request_method;
          proxy_set_header X-Forwarded-Method $request_method;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-Uri $request_uri;
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header Content-Length "";
          proxy_set_header Connection "";

          ## Basic Proxy Configuration
          proxy_pass_request_body off;
          proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; # Timeout if the real server is dead
          proxy_redirect http:// $scheme://;
          proxy_http_version 1.1;
          proxy_cache_bypass $cookie_session;
          proxy_no_cache $cookie_session;
          proxy_buffers 4 32k;
          client_body_buffer_size 128k;

          ## Advanced Proxy Configuration
          send_timeout 5m;
          proxy_read_timeout 240;
          proxy_send_timeout 240;
          proxy_connect_timeout 240;
        '';
        locations."/".extraConfig = ''
          ## Send a subrequest to Authelia to verify if the user is authenticated and has permission to access the resource.
          auth_request /authelia;

          ## Set the $target_url variable based on the original request.

          ## Requires nginx http_set_misc module.
          set_escape_uri $target_url $scheme://$http_host$request_uri;

          ## Save the upstream response headers from Authelia to variables.
          auth_request_set $user $upstream_http_remote_user;
          auth_request_set $groups $upstream_http_remote_groups;
          auth_request_set $name $upstream_http_remote_name;
          auth_request_set $email $upstream_http_remote_email;

          ## Inject the response headers from the variables into the request made to the backend.
          proxy_set_header Remote-User $user;
          proxy_set_header Remote-Groups $groups;
          proxy_set_header Remote-Name $name;
          proxy_set_header Remote-Email $email;

          ## If the subreqest returns 200 pass to the backend, if the subrequest returns 401 redirect to the portal.
          error_page 401 =302 https://auth.zx.dev/?rd=$target_url;
        '';
      };
    };

  vhostOptionsProxy =
    { config, ... }:
    {
      options = {
        useAutheliaProxyConf = lib.mkEnableOption "Use recommended authelia proxy configuration";
      };
      config = lib.mkIf config.useAutheliaProxyConf {
        locations."/".extraConfig = ''
          ## Headers
          proxy_set_header Host $host;
          proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-Uri $request_uri;
          proxy_set_header X-Forwarded-Ssl on;
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header Connection "";

          ## Basic Proxy Configuration
          client_body_buffer_size 128k;
          proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; ## Timeout if the real server is dead.
          proxy_redirect  http://  $scheme://;
          proxy_http_version 1.1;
          proxy_cache_bypass $cookie_session;
          proxy_no_cache $cookie_session;
          proxy_buffers 64 256k;

          ## Trusted Proxies Configuration
          ## Please read the following documentation before configuring this:
          ##     https://www.authelia.com/integration/proxies/nginx/#trusted-proxies
          # set_real_ip_from 10.0.0.0/8;
          # set_real_ip_from 172.16.0.0/12;
          # set_real_ip_from 192.168.0.0/16;
          # set_real_ip_from fc00::/7;
          real_ip_header X-Forwarded-For;
          real_ip_recursive on;

          ## Advanced Proxy Configuration
          send_timeout 5m;
          proxy_read_timeout 360;
          proxy_send_timeout 360;
          proxy_connect_timeout 360;
        '';
      };
    };
in
{
  options = {
    services.nginx-authelia = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 9091;
      };
    };

    services.nginx.virtualHosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule [
          vhostOptionsAuth
          vhostOptionsProxy
        ]
      );
    };
  };

  config = { };
}
