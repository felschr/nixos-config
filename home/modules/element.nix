{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.element;

  mkBadgedIcon = import ./firefox/mkBadgedIcon.nix { inherit pkgs; };

  mkProfilePackage =
    profileName:
    {
      desktopName,
      badge,
      ...
    }:
    let
      pname = "element-${profileName}";
      badgedIcon = mkBadgedIcon {
        pkg = pkgs.element-desktop;
        baseName = "element";
        name = pname;
        inherit badge;
      };
      scriptBin = pkgs.writeScriptBin pname ''
        ${pkgs.element-desktop}/bin/element-desktop --profile "${profileName}" "$@"
      '';
      desktopFile = pkgs.makeDesktopItem {
        name = pname;
        exec = "${scriptBin}/bin/${pname} %U";
        icon = if badge == null then "element" else pname;
        desktopName = if desktopName != null then desktopName else "Element (${profileName})";
        genericName = "Matrix Client";
        mimeTypes = [ ];
        categories = [
          "Network"
          "InstantMessaging"
          "Chat"
        ];
      };
    in
    pkgs.runCommand pname { } ''
      mkdir -p $out/{bin,share}
      cp -r ${scriptBin}/bin/${pname} $out/bin/${pname}
      cp -r ${desktopFile}/share/applications $out/share/applications
      ${lib.optionalString (badge != null) "cp -r ${badgedIcon}/share/icons $out/share/icons"}
    '';

  badgeType =
    with lib.types;
    let
      badgeSubmodule = lib.types.submodule {
        options = {
          text = lib.mkOption {
            type = str;
            example = "W";
            description = "Text shown in the badge, usually a single letter.";
          };
          color = lib.mkOption {
            type = str;
            default = "#ffffff";
            description = "Badge background color.";
          };
          textColor = lib.mkOption {
            type = str;
            default = "#000000";
            description = "Badge text color.";
          };
        };
      };
    in
    nullOr badgeSubmodule;
in
{
  options.programs.element = {
    enable = lib.mkEnableOption "Element Desktop";
    autostart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start Element Desktop hidden at login.";
    };
    profiles = lib.mkOption {
      default = { };
      description = ''
        Additional Element Desktop instances, each run with its own `--profile`
        and launched through `element-''${name}`.
      '';
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "a separate Element Desktop instance for this profile";
            autostart = lib.mkEnableOption "starting this Element Desktop instance hidden at login";
            desktopName = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Desktop entry name. Defaults to `Element ({name})`.";
            };
            badge = lib.mkOption {
              type = badgeType;
              default = null;
              description = ''
                Colored corner badge overlaid on the `element-''${name}` icon.
                When null (default), the entry keeps the plain Element icon.
              '';
            };
          };
        }
      );
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = [
        pkgs.element-desktop
      ]
      ++ lib.optional cfg.autostart (
        pkgs.makeAutostartItem {
          name = "element-desktop";
          package = pkgs.element-desktop;
          prependExtraArgs = [ "--hidden" ];
        }
      );
    })
    {
      home.packages = lib.concatLists (
        lib.mapAttrsToList (
          profileName: profile:
          let
            package = mkProfilePackage profileName profile;
          in
          [ package ]
          ++ lib.optional profile.autostart (
            pkgs.makeAutostartItem {
              name = "element-${profileName}";
              inherit package;
              prependExtraArgs = [ "--hidden" ];
            }
          )
        ) (lib.filterAttrs (_: profile: profile.enable) cfg.profiles)
      );
    }
  ];
}
