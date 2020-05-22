{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.programs.git.custom;
  defaultProfiles = {
    private = {
      name       = "Felix Tenley";
      email      = "dev@felschr.com";
      signingKey = "22A6 DD21 EE66 E73D D4B9  3F20 A12D 7C9D 2FD3 4458";
      dirs       = [ "/etc/nixos/" ];
    };
    work = {
      name       = "Felix Schröter";
      email      = "fs@upsquared.com";
      signingKey = "6DA1 4A05 C6E0 7DBE EB81  BA24 28ED 46BC B881 7B7A";
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
