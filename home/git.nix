{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.programs.git.custom;
in
{
  options.programs.git.custom = {
    userName = mkOption {
      type    = types.str;
      default = "Felix Tenley";
    };
    userEmail = mkOption {
      type    = types.str;
      default = "dev@felschr.com";
    };
    signingKey = mkOption {
      type = types.str;
    };
  };

  config = {
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      ignores = [".direnv"];
      signing = {
        key = cfg.signingKey;
        signByDefault = true;
      };
      extraConfig = {
        pull = { rebase = true; };
        rebase = { autoStash = true; };
      };
    };
  };
}
