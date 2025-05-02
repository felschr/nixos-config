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
        dirs = [
          "~/dev/private/"
          "/etc/nixos"
        ];
      };
      work = {
        name = "Felix Schröter";
        email = "felix.schroeter@cmdscale.com";
        # use sign subkey's fingerprint: gpg2 -K --with-subkey-fingerprint
        signingKey = "5A9D CC6B F70A C69B B0D7  C755 A3A2 2573 CA6D 0E38";
        dirs = [ "~/dev/work/" ];
      };
    };

    ignores = [ ".direnv" ];
    signing = {
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
      # usage: git mr <source> <MR number> (git mr origin 1010)
      mr = "!sh -c 'git fetch $1 merge-requests/$2/head:mr-$1-$2 && git checkout mr-$1-$2' -";
      # usage: git pr <source> <PR number> (git pr origin 1010)
      pr = "!sh -c 'git fetch $1 pull/$2/head:pr/$2 && git checkout pr/$2' -";
      # delete branches locally that have already been merged
      # usage: git clean-branches <branch> (branch to check against, defaults to main)
      clean-branches = ''!sh -c 'git branch --merged "''${1:-main}" | egrep -v "(^\*|master|main|staging|production)" | xargs git branch -d' -'';
    };
  };
}
