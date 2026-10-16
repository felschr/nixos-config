{
  modulePath,
  name,
  packageName,
  isSecure ? false,
}:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  appName = name;
  cfg = lib.getAttrFromPath modulePath config;

  mkBadgedIcon = import ./mkBadgedIcon.nix { inherit pkgs; };

  mkProfileBin =
    profileName: bin:
    let
      pname = "${packageName}-${profileName}";
      badge = bin.badge;
      badgedIcon =
        if badge == null then
          null
        else
          mkBadgedIcon {
            pkg = cfg.package;
            baseName = packageName;
            name = pname;
            inherit badge;
          };
      scriptBin = pkgs.writeScriptBin pname ''
        ${packageName} -P "${profileName}" --name="${pname}" $@
      '';
      desktopFile = pkgs.makeDesktopItem {
        name = pname;
        exec = "${scriptBin}/bin/${pname} %U";
        icon = if badge == null then packageName else pname;
        extraConfig.StartupWMClass = pname;
        desktopName = if bin.desktopName != null then bin.desktopName else "${appName} (${profileName})";
        genericName = "Web Browser";
        mimeTypes = bin.mimeTypes;
        categories = [
          "Network"
          "WebBrowser"
        ]
        ++ lib.optional isSecure "Security";
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
            default = "#2da44e";
            description = "Badge background color.";
          };
          textColor = lib.mkOption {
            type = str;
            default = "#ffffff";
            description = "Badge text color.";
          };
        };
      };
    in
    nullOr badgeSubmodule;
in
{
  options = lib.setAttrByPath modulePath {
    profiles = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.bin = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = ''
                    Whether to install a `${packageName}-''${profile}` bin and `.desktop` entry
                    for this profile.
                  '';
                };
                desktopName = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "Desktop entry name. Defaults to `${appName} ({profile})`.";
                };
                badge = lib.mkOption {
                  type = badgeType;
                  default = null;
                  description = ''
                    Colored corner badge overlaid on the `${packageName}-''${profile}` icon.
                    When null (default), the bin keeps the plain `${packageName}` icon.
                  '';
                };
                mimeTypes = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [
                    "text/html"
                    "text/xml"
                    "application/xhtml+xml"
                    "application/vnd.mozilla.xul+xml"
                    "x-scheme-handler/http"
                    "x-scheme-handler/https"
                  ];
                  description = ''
                    MIME types (incl. URL schemes) that the `.desktop` entry registers as a
                    handler for. Set to `[ ]` to keep the bin out of the default-app lists.
                  '';
                };
              };
            };
            default = { };
            description = ''
              Settings for an optional launcher bin `${packageName}-''${profile}`, coming with
              a `.desktop` file configured to show a separate window icon (on GNOME at least).
            '';
          };
        }
      );
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mapAttrsToList (profileName: profile: mkProfileBin profileName profile.bin) (
      lib.filterAttrs (_: profile: profile.bin.enable) cfg.profiles
    );
  };
}
