{ inputs, ... }:

let createUser' = import ./createUser.nix;
in {
  flake = {
    lib = {
      createSystem = hostName:
        { hardwareConfig, config }:
        ({ pkgs, lib, ... }: {
          networking.hostName = hostName;

          imports = [ ../modules/common.nix hardwareConfig config ];
        });
      createUser = name: args:
        ({ pkgs, ... }@args2:
          (createUser' name args)
          ({ inherit (inputs) home-manager; } // args2));
      createMediaGroup = _: { users.groups.media.gid = 600; };
    };
  };
}
