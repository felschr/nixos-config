{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.programs.git.custom;
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
    };
    defaultProfile = mkOption {
      type = types.str;
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
        init = {
          defaultBranch = "main";
        };
        pull = {
          rebase = true;
        };
        rebase = {
          autoStash = true;
          autoSquash = true;
          abbreviateCommands = true;
          missingCommitsCheck = "warn";
        };
      };
      aliases = {
        mr = "!sh -c 'git fetch $1 merge-requests/$2/head:mr-$1-$2 && git checkout mr-$1-$2' -";
        pr = "!sh -c 'git fetch $1 refs/pull/$2/head:pr/$1 && git checkout pr/$2'";
      };
      includes = flatten (mapAttrsToList (name: profile: map (dir: {
        condition = "gitdir:${dir}";
        contents = {
          user = {
            name = profile.name;
            email = profile.email;
            signingKey = profile.signingKey;
          };
        };
      }) profile.dirs) profiles);
    };
  };
}
