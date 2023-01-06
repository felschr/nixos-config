{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    profiles = {
      private = {
        name = "Felix Schröter";
        email = "dev@felschr.com";
        # use sign subkey's fingerprint: gpg2 -K --with-subkey-fingerprint
        signingKey = "7E08 6842 0934 AA1D 6821  1F2A 671E 39E6 744C 807D";
        dirs = [ "~/dev/private/" "/etc/nixos" ];
      };
      work = {
        name = "Felix Schröter";
        email = "fs@upsquared.com";
        # use sign subkey's fingerprint: gpg2 -K --with-subkey-fingerprint
        signingKey = "16F6 4623 8B1C 80C4 6267  6FF9 4D13 24C5 006E 9B2E";
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
      # usage: git mr <source> <MR number> (git mr origin 1010)
      mr =
        "!sh -c 'git fetch $1 merge-requests/$2/head:mr-$1-$2 && git checkout mr-$1-$2' -";
      # usage: git pr <source> <PR number> (git pr origin 1010)
      pr = "!sh -c 'git fetch $1 pull/$2/head:pr/$2 && git checkout pr/$2' -";
    };
  };
}
