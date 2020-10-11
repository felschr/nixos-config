{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    profiles = {
      private = {
        name = "Felix Tenley";
        email = "dev@felschr.com";
        signingKey = "6AB3 7A28 5420 9A41 82D9  0068 910A CB9F 6BD2 6F58";
        dirs = [ "~/dev/private/" "/etc/nixos" ];
      };
      work = {
        name = "Felix Schröter";
        email = "fs@upsquared.com";
        signingKey = "F28B FB74 4421 7580 5A49  2930 BE85 F0D9 987F A014";
        dirs = [ "~/dev/work/" ];
      };
    };

    ignores = [ ".direnv" ];
    signing = { signByDefault = true; };
    extraConfig = {
      init = { defaultBranch = "main"; };
      pull = { rebase = true; };
      rebase = {
        autoStash = true;
        autoSquash = true;
        abbreviateCommands = true;
        missingCommitsCheck = "warn";
      };
    };
    aliases = {
      mr =
        "!sh -c 'git fetch $1 merge-requests/$2/head:mr-$1-$2 && git checkout mr-$1-$2' -";
      pr =
        "!sh -c 'git fetch $1 refs/pull/$2/head:pr/$1 && git checkout pr/$2'";
    };
  };
}
