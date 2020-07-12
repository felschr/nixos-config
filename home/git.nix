{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.programs.git.custom;
  defaultProfiles = {
    private = {
      name       = "Felix Tenley";
      email      = "dev@felschr.com";
      signingKey = "6AB3 7A28 5420 9A41 82D9  0068 910A CB9F 6BD2 6F58";
      dirs       = [ "/etc/nixos/" ];
    };
    work = {
      name       = "Felix Schröter";
      email      = "fs@upsquared.com";
      signingKey = "F28B FB74 4421 7580 5A49  2930 BE85 F0D9 987F A014";
      dirs       = [ "~/dev/" ];
    };
  };
in
{
  options.programs.git.custom = {
    profiles = mkOption {
      type = types.attrsOf (types.submodule ({ name, config, ... }: {
        options = {
          name = mkOption {
            type = types.str;
          };
          email = mkOption {
            type = types.str;
          };
          signingKey = mkOption {
            type = types.str;
          };
          dirs = mkOption {
            type = types.listOf types.str;
          };
        };
      }));
      default = defaultProfiles;
    };
    defaultProfile = mkOption {
      type    = types.str;
      default = "private";
    };
  };

  config = let
    profiles = cfg.profiles;
  in {
    programs.git = {
      enable = true;
      userName = profiles."${cfg.defaultProfile}".name;
      userEmail = profiles."${cfg.defaultProfile}".email;
      ignores = [".direnv"];
      signing = {
        key = profiles."${cfg.defaultProfile}".signingKey;
        signByDefault = true;
      };
      extraConfig = {
        pull = { rebase = true; };
        rebase = { autoStash = true; };
      };
      includes = flatten (mapAttrsToList (name: profile: map (dir: {
        condition = "gitdir:${dir}";
        contents = {
          user = {
            name = profile.name;
            email = profile.email;
            signingkey = profile.signingKey;
          };
        };
      }) profile.dirs) profiles);
    };
  };
}
