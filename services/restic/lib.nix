{
  config,
  lib,
  pkgs,
  ...
}:

# using the restic cli:
# load credentials into shell by adding B2 secrets to .env (see .env.example).
# useful commands for analysing restic stats [snapshot-id], restic diff [s1] [s2],

with lib;
with builtins;
let
  hasAnyAttr = flip (attrset: any (flip hasAttr attrset));
in
{
  resticConfig =
    args@{
      name,
      paths ? [ ],
      ignorePatterns ? [ ],
      extraBackupArgs ? [ ],
      extraPruneOpts ? [ ],
      ...
    }:
    assert
      !hasAnyAttr [
        "initialize"
        "repository"
        "s3CredentialsFile"
        "passwordFile"
        "pruneOpts"
      ] args;
    assert (args ? paths);
    {
      initialize = true;
      repository = "b2:felschr-backups:/${name}";
      environmentFile = config.age.secrets.restic-b2.path;
      passwordFile = config.age.secrets.restic-password.path;
      timerConfig.OnCalendar = "daily";
      inherit paths;
      extraBackupArgs =
        let
          ignoreFile = builtins.toFile "ignore" (foldl (a: b: a + "\n" + b) "" ignorePatterns);
        in
        [ "--exclude-file=${ignoreFile}" ] ++ extraBackupArgs;
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
        "--keep-yearly 1"
        # reduce download bandwidth
        "--max-unused 10%"
        "--repack-cacheable-only"
      ]
      ++ extraPruneOpts;
    }
    // (removeAttrs args [
      "name"
      "paths"
      "ignorePatterns"
      "extraBackupArgs"
      "extraPruneOpts"
    ]);
}
