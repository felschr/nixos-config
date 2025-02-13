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

  mkProfileBin =
    profileName: profile:
    let
      pname = "${packageName}-${profileName}";
      scriptBin = pkgs.writeScriptBin pname ''
        ${packageName} -P "${profileName}" --name="${pname}" $@
      '';
      desktopFile = pkgs.makeDesktopItem {
        name = pname;
        exec = "${scriptBin}/bin/${pname} %U";
        icon = packageName;
        extraConfig.StartupWMClass = pname;
        desktopName = "${appName} (${profileName})";
        genericName = "Web Browser";
        categories = [
          "Network"
          "WebBrowser"
        ] ++ lib.optional isSecure "Security";
      };
    in
    pkgs.runCommand pname { } ''
      mkdir -p $out/{bin,share}
      cp -r ${scriptBin}/bin/${pname} $out/bin/${pname}
      cp -r ${desktopFile}/share/applications $out/share/applications
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
