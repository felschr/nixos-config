{
  config,
  lib,
  inputs,
  ...
}:

# Tool for Spanish digital certificates FNMT-RCM
{
  imports = [ inputs.autofirma-nix.homeManagerModules.default ];

  programs.configuradorfnmt.enable = true;
  programs.configuradorfnmt.firefoxIntegration.profiles = {
    private.enable = true;
  };

  # programs.mullvad-browser.profiles = lib.flip lib.mapAttrs
  #   config.programs.configuradorfnmt.firefoxIntegration.profiles (name:
  #     { enable, ... }: {
  #       settings = lib.mkIf enable {
  #         "network.protocol-handler.app.fnmtcr" =
  #           "${config.programs.configuradorfnmt.finalPackage}/bin/configuradorfnmt";
  #         "network.protocol-handler.warn-external.fnmtcr" = false;
  #         "network.protocol-handler.external.fnmtcr" = true;
  #       };
  #     });
}
