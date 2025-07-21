{
  config,
  inputs,
  pkgs,
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
    package = pkgs.unstable.ollama;
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
