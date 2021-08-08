name:
{ user ? { }, hm ? { }, modules ? [ ], config, ... }:

{ pkgs, lib, home-manager, ... }: {
  imports = [ home-manager.nixosModules.home-manager ];

  users.users."${name}" = {
    isNormalUser = true;
    shell = pkgs.zsh;
  } // user;

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users."${name}" = lib.mkMerge [ { imports = modules; } (import config) ];
  } // hm;
}
