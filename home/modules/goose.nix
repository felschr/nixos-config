{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.programs.goose;
  yaml = pkgs.formats.yaml { };
  configFile = yaml.generate "goose-config.yaml" cfg.settings;
in
{
  options.programs.goose = {
    enable = lib.mkEnableOption "goose coding agent";

    package = lib.mkOption {
      type = lib.types.package;
      description = "goose package to install.";
    };

    settings = lib.mkOption {
      type = lib.types.nullOr yaml.type;
      default = null;
      description = ''
        Settings written declaratively to {file}`~/.config/goose/config.yaml`.
        This is the last of goose's config layers
        (`/etc/goose/config.yaml` &lt; `$GOOSE_ADDITIONAL_CONFIG_FILES` &lt; user
        config), so it wins for declared keys while still allowing edits at
        runtime; those runtime changes are overwritten by the declared values
        again on the next `home-manager switch`.
        The file is deployed as a writable regular file (not a read-only store
        symlink) because goose acquires an flock and atomically rewrites the
        write path at runtime, which would otherwise fail against /nix/store.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.activation.gooseConfig = lib.mkIf (cfg.settings != null) {
      before = [ ];
      after = [ "writeBoundary" ];
      data = ''
        run mkdir -p "$HOME/.config/goose"
        run install -m 600 ${configFile} "$HOME/.config/goose/config.yaml"
      '';
    };
  };
}
