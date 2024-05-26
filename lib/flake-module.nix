{ inputs, lib, ... }:

let
  createUser' = import ./createUser.nix;
in
{
  imports = [ ./openwrt.nix ];
  options.flake.lib = lib.mkOption { type = with lib.types; lazyAttrsOf raw; };
  config.flake.lib = {
    createSystem =
      hostName:
      { hardwareConfig, config }:
      (
        { pkgs, lib, ... }:
        {
          networking.hostName = hostName;

          imports = [
            ../modules/common.nix
            hardwareConfig
            config
          ];
        }
      );
    createUser =
      name: args:
      ({ pkgs, ... }@args2: (createUser' name args) ({ inherit (inputs) home-manager; } // args2));
    createMediaGroup = _: { users.groups.media.gid = 600; };
  };
}
