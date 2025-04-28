{ lib, ... }:

{
  imports = [
    ./createUser.nix
    ./openwrt.nix
  ];
  options.flake.lib = lib.mkOption { type = with lib.types; lazyAttrsOf raw; };
  config.flake.lib = {
    createSystemModule =
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
    createMediaGroup = _: { users.groups.media.gid = 600; };
  };
}
