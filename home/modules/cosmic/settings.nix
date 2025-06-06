{ lib, ... }:

# Known definitions for settings options

let
  inherit (lib) types;
  ron = import ./ron.nix { inherit lib; };
  cosmic = {
    types = import ./types.nix { inherit lib ron; };
  };
in
{
  options.programs.cosmic.settings = {
    # https://github.com/pop-os/libcosmic/blob/1fce5df160f595d1b1e5a8e2bb2a24775419f82d/src/config/mod.rs#L85
    "com.system76.CosmicTk".v1 = {
      apply_theme_global = lib.mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Apply the theme to other toolkits.";
      };
      show_minimize = lib.mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Show minimize button in window header.";
      };
      show_maximize = lib.mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Show maximize button in window header.";
      };
      icon_theme = lib.mkOption {
        type = types.nullOr ron.types.str;
        default = null;
        description = "Preferred icon theme.";
      };
      header_size = lib.mkOption {
        type = types.nullOr cosmic.types.density;
        default = null;
        description = "Density of CSD/SSD header bars.";
      };
      interface_density = lib.mkOption {
        type = types.nullOr cosmic.types.density;
        default = null;
        description = "Interface density.";
      };
      interface_font = lib.mkOption {
        type = types.nullOr cosmic.types.font_config;
        default = null;
        description = "Interface font family";
      };
      monospace_font = lib.mkOption {
        type = types.nullOr cosmic.types.font_config;
        default = null;
        description = "Mono font family";
      };
    };

    # https://github.com/pop-os/cosmic-files/blob/1a5a4501ee501b3155295cbfccc1c992b5ec9c01/src/config.rs#L106
    "com.system76.CosmicFiles".v1 = {
      app_theme = lib.mkOption {
        type = types.nullOr cosmic.types.theme;
        default = null;
        description = "";
      };
      desktop = lib.mkOption {
        type = types.nullOr cosmic.types.files_desktop;
        default = null;
        description = "";
      };
      favorites = lib.mkOption {
        type = types.nullOr cosmic.types.files_favorites;
        default = null;
        description = "";
      };
      show_details = lib.mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "";
      };
      tab = lib.mkOption {
        type = types.nullOr cosmic.types.files_tab_config;
        default = null;
        description = "";
      };
      type_to_search = lib.mkOption {
        type = types.nullOr (
          types.enum [
            "Recursive"
            "EnterPath"
          ]
        );
        default = null;
        description = "";
      };
    };

    # https://github.com/pop-os/cosmic-applets/blob/b4b465712218be8d26b6772a382d19f4c3ff97f8/cosmic-applet-audio/src/config.rs#L9
    "com.system76.CosmicAppletAudio".v1 = {
      show_media_controls_in_top_panel = lib.mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "";
      };
    };

    # ...
  };
}
