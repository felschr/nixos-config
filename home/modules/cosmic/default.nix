{ config, lib, ... }:

# Based on:
# https://github.com/tristanbeedell/home-manager/tree/efa4d272f6c2b14d4a3b67b0b1e4b38ae46e5588/modules/programs/cosmic

let
  cfg = config.programs.cosmic;

  ron = import ./ron.nix { inherit lib; };
in
{
  imports = [ ./settings.nix ];

  options.programs.cosmic = {
    enable = lib.mkEnableOption "COSMIC Desktop";
    settings = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        freeformType = lib.types.submodule {
          freeformType = lib.types.attrsOf lib.types.anything;
        };
      };
      description = ''
        An attrset of explicit settings for COSMIC apps, using their full config path.
      '';
      example = lib.literalExpression ''
        {
          "com.system76.CosmicPanel.Dock".v1 = {
            opacity = 0.8;
          };
        };
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile = lib.concatMapAttrs (
      component:
      lib.concatMapAttrs (
        version:
        lib.concatMapAttrs (
          option: value:
          lib.optionalAttrs (value != null) {
            "cosmic/${component}/${version}/${option}" = {
              enable = true;
              text = ron.serialise value;
            };
          }
        )
      )
    ) cfg.settings;
  };
}
