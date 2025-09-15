{ modulePath, ... }@moduleArgs:

{
  inputs,
  config,
  lib,
  ...
}:

let
  mkFirefoxModule = import "${inputs.home-manager.outPath}/modules/programs/firefox/mkFirefoxModule.nix";

  cfg = lib.getAttrFromPath modulePath config;

  # HINT home-manager's Firefox module uses a read-only `finalPackage` option
  # that creates a wrapper around `package`. However, this wrapper is not
  # compatible with all Firefox-based browser packages. Thus, we adjust the module
  # to always set `finalPackage` to `package` & remove unsupported options.
  fixFirefoxModuleCompat =
    module:
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      optionsPath = [ "options" ] ++ modulePath;
      configPath = [
        "config"
        "content" # due to mkIf
      ]
      ++ modulePath;
    in
    lib.updateManyAttrsByPath
      [
        {
          path = optionsPath ++ [ "languagePacks" ];
          update = old: { };
        }
        {
          path = configPath ++ [ "finalPackage" ];
          update = old: cfg.package;
        }
        {
          path = configPath ++ [ "policies" ];
          update = old: { };
        }
      ]
      (module {
        inherit config lib pkgs;
      });
in
{
  imports = [
    (fixFirefoxModuleCompat (mkFirefoxModule moduleArgs))
  ];

  options = lib.setAttrByPath modulePath { };

  config = lib.mkIf cfg.enable (
    { }
    // lib.setAttrByPath modulePath {
      # Tor & Mullvad Browser don't support profile version 2 yet
      profileVersion = lib.mkDefault null;
    }
  );
}
