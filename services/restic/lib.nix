{ config, lib, pkgs, ... }:

# using the restic cli:
# load credentials into shell via: export $(cat /path/to/credentials/file | xargs)
# useful commands for analysing restic stats [snapshot-id], restic diff [s1] [s2],

with lib;
with builtins;
let hasAnyAttr = flip (attrset: any (flip hasAttr attrset));
in {
  resticConfig = args@{ name, ripgrep ? false, paths ? [ ], ignorePatterns ? [ ]
    , extraPruneOpts ? [ ], ... }:
    assert !hasAnyAttr [
      "initialize"
      "repository"
      "s3CredentialsFile"
      "passwordFile"
      "pruneOpts"
    ] args;
    assert (args ? paths);
    assert (ripgrep || (!ripgrep && !(args ? ignorePatterns)));
    {
      initialize = true;
      repository = "b2:felschr-backups:/${name}";
      environmentFile = config.age.secrets.restic-b2.path;
      passwordFile = config.age.secrets.restic-password.path;
      timerConfig.OnCalendar = "daily";
      paths = if ripgrep then null else paths;
      dynamicFilesFrom = if ripgrep then
        let
          files = foldl (a: b: "${a} ${b}") "" paths;
          ignoreFile = builtins.toFile "ignore"
            (foldl (a: b: a + "\n" + b) "" ignorePatterns);
        in ''
          ${pkgs.fd}/bin/fd \
            --hidden \
            --ignore-file ${ignoreFile} \
            . ${files} \
            | sed "s/\[/\\\[/" | sed "s/\]/\\\]/"
        ''
      else
        null;
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
        "--keep-yearly 1"
      ] ++ extraPruneOpts;
    } // (removeAttrs args [
      "name"
      "ripgrep"
      "paths"
      "ignorePatterns"
      "extraPruneOpts"
    ]);
}
