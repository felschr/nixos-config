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
    profileName: profile:
    let
      pname = "${packageName}-${profileName}";
      badge = cfg.iconBadges.${profileName} or null;
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
        desktopName = "${appName} (${profileName})";
        genericName = "Web Browser";
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
in
{
  options = lib.setAttrByPath modulePath {
    createProfileBins = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        When enabled installs a binary for all non-default profiles named `${packageName}-''${profile}`.
        This also includes a `.desktop` file that is configured to show separate icons (on GNOME at least).
      '';
    };
    iconBadges = lib.mkOption {
      type =
        with lib.types;
        attrsOf (submodule {
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
        });
      default = { };
      description = ''
        Colored corner badges overlaid on `${packageName}`-derived profile bin icons.
        Keys are profile names; profile bins without a badge keep the plain `${packageName}` icon.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    {
      home.packages =
        if cfg.createProfileBins then
          (lib.mapAttrsToList mkProfileBin) (lib.filterAttrs (_: p: !p.isDefault) cfg.profiles)
        else
          [ ];
    }
    // lib.setAttrByPath modulePath { }
  );
}
