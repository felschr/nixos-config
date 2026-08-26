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
          # HINT Firefox resolves the default profile via a hash of its install
          # path. Since that path is a Nix store path, every browser update
          # changes the hash & Firefox can neither resolve nor persist a
          # default (profiles.ini is read-only), causing it to open the profile
          # selector or spawn throwaway profiles. To avoid this we inject the
          # declarative default profile into launches unless one was chosen
          # explicitly.
          update =
            old:
            let
              browserName = cfg.package.browserName or (builtins.parseDrvName cfg.package.name).name;
              browserBin = "${cfg.package}/bin/${browserName}";
              defaultProfile = lib.findFirst (p: p.isDefault) null (lib.attrValues cfg.profiles);
              pinProfileArgs = lib.optionalString (defaultProfile != null) (
                "-P ${lib.escapeShellArg defaultProfile.name}"
              );
              pinnedBin = pkgs.writeShellScriptBin browserName ''
                for arg in "$@"; do
                  case "$arg" in
                    -[Pp] | --profile | -profile | --profile=* | -profile=*)
                      exec "${browserBin}" "$@"
                      ;;
                    -[Pp]rofile[Mm]anager | --[Pp]rofile[Mm]anager)
                      exec "${browserBin}" "$@"
                      ;;
                    -[Cc]reate[Pp]rofile | --[Cc]reate[Pp]rofile)
                      exec "${browserBin}" "$@"
                      ;;
                  esac
                done
                exec "${browserBin}" ${pinProfileArgs} "$@"
              '';
            in
            if pinProfileArgs == "" then
              cfg.package
            else
              pkgs.symlinkJoin {
                name = "${cfg.package.name}-profile-pinned";
                paths = [
                  pinnedBin
                  cfg.package
                ];
                ignoreCollisions = true;
              };
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
