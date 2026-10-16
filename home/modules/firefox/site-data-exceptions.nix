{
  modulePath,
  name,
  packageName,
}:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = lib.getAttrFromPath modulePath config;

  profileBase = "${config.home.homeDirectory}/${cfg.configPath}";

  exceptionsFile =
    if cfg.siteDataExceptionsFile != null then
      cfg.siteDataExceptionsFile
    else if cfg.siteDataExceptions != { } then
      pkgs.writeText "${packageName}-site-data-exceptions.toml" (
        lib.concatStrings (
          lib.mapAttrsToList (profileName: origins: ''
            ${profileName} = [
              ${lib.concatMapStringsSep ",\n  " (origin: ''"${origin}"'') origins}
            ]
          '') cfg.siteDataExceptions
        )
      )
    else
      null;

  # the sync logic lives in a standalone nushell script so it can also be
  # run directly & interactively
  syncExceptionsScript = ../../../scripts/firefox-sync-exceptions.nu;

  syncScript = pkgs.writeShellScriptBin "sync-${packageName}-site-data-exceptions" ''
    exec ${pkgs.nushell}/bin/nu ${syncExceptionsScript} \
      --browser "${profileBase}" \
      --config "${exceptionsFile}" \
      --yes
  '';
in
{
  options =
    lib.recursiveUpdate
      (lib.setAttrByPath (modulePath ++ [ "siteDataExceptions" ]) (
        lib.mkOption {
          type = lib.types.attrsOf (lib.types.listOf lib.types.str);
          default = { };
          description = "Site data & cookie exception origins per profile for ${name}, declared inline as a Nix attribute set.";
        }
      ))
      (
        lib.setAttrByPath (modulePath ++ [ "siteDataExceptionsFile" ]) (
          lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to a TOML file mapping profile names to lists of site data & cookie exception origins for ${name}. Takes precedence over <option>siteDataExceptions</option>.";
          }
        )
      );

  config = lib.mkIf (cfg.enable && exceptionsFile != null) {
    home.activation."${packageName}SiteDataExceptions" = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${syncScript}/bin/sync-${packageName}-site-data-exceptions
    '';
  };
}
