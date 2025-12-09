{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

{
  disabledModules = [
    "services/misc/ollama.nix"
    "services/misc/open-webui.nix"
  ];

  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/ollama.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/open-webui.nix"
  ];

  services.ollama = {
    enable = true;
    package = lib.mkDefault pkgs.unstable.ollama-vulkan;
    host = "0.0.0.0";
  };

  services.open-webui = {
    enable = true;
    package = pkgs.unstable.open-webui;
    host = "0.0.0.0";
    port = 11111;
    environment = {
      WEBUI_AUTH = "False";
      OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString config.services.ollama.port}";
    };
  };
}
