{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
let
  cfg = config.programs.git;
in
{
  options.programs.git = {
    profiles = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, config, ... }:
          {
            options = {
              name = mkOption { type = types.str; };
              email = mkOption { type = types.str; };
              signingKey = mkOption { type = types.str; };
              dirs = mkOption { type = types.listOf types.str; };
            };
          }
        )
      );
    };
    defaultProfile = mkOption { type = types.str; };
  };

  config =
    let
      inherit (cfg) profiles;
    in
    {
      programs.git = {
        # fix/workaround for https://github.com/NixOS/nixpkgs/issues/169193
        extraConfig.safe.directory = "/etc/nixos";

        userName = profiles."${cfg.defaultProfile}".name;
        userEmail = profiles."${cfg.defaultProfile}".email;
        signing = {
          key = profiles."${cfg.defaultProfile}".signingKey;
        };
        includes = flatten (
          mapAttrsToList (
            name: profile:
            map (dir: {
              condition = "gitdir:${dir}";
              contents.user = {
                inherit (profile) name email signingKey;
              };
            }) profile.dirs
          ) profiles
        );
      };
    };
}
