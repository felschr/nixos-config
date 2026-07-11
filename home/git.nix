{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    profiles = {
      private = {
        name = "Felix Schröter";
        email = "dev@felschr.com";
        signingKey = "~/.ssh/private_sign";
        dirs = [
          "~/dev/private/"
          "/etc/nixos/"
        ];
      };
      work = {
        name = "Felix Schröter";
        email = "felix@atvari.eu";
        signingKey = "~/.ssh/atvari_sign";
        dirs = [ "~/dev/work/" ];
      };
    };

    ignores = [ ".direnv" ];
    signing = {
      format = "ssh";
      signByDefault = true;
    };
    settings = {
      gpg.ssh.allowedSignersFile = builtins.toFile "allowed_signers" ''
        dev@felschr.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODQ95mDuh+6PBPduwTEbc48IjPTD4TZNuDh6y74/xoy
        felix@atvari.eu ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII368Kw6AoBCUrXjYXwOnSTShdDHYhvEA1/imRcGkDE/
      '';
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
      alias = {
        # usage: git mr <source> <MR number> (git mr origin 1010)
        mr = "!sh -c 'git fetch $1 merge-requests/$2/head:mr-$1-$2 && git checkout mr-$1-$2' -";
        # usage: git pr <source> <PR number> (git pr origin 1010)
        pr = "!sh -c 'git fetch $1 pull/$2/head:pr/$2 && git checkout pr/$2' -";
        # delete branches locally that have already been merged
        # usage: git clean-branches <branch> (branch to check against, defaults to main)
        clean-branches = ''!sh -c 'git branch --merged "''${1:-main}" | egrep -v "(^\*|master|main|staging|production)" | xargs git branch -d' -'';
      };
    };
  };
}
