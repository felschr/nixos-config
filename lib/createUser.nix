name:
{ user ? { }, hm ? { }, modules ? [ ], config, usesContainers ? false, ... }:

{ inputs, nixConfig, pkgs, lib, home-manager, ... }: {
  imports = [ home-manager.nixosModules.home-manager ];

  users.users."${name}" = {
    isNormalUser = true;
    shell = pkgs.zsh;

    # increase sub{u,g}id range for container user namespaces
    subUidRanges = lib.optionals usesContainers [{
      startUid = 100000;
      count = 60000000;
    }];
    subGidRanges = lib.optionals usesContainers [{
      startGid = 100000;
      count = 60000000;
    }];
  } // user;

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users."${name}" = lib.mkMerge [ { imports = modules; } (import config) ];
    extraSpecialArgs = { inherit inputs nixConfig; };
  } // hm;
}
