{ config, pkgs, lib, ... }:

{
  imports = [ ../../modules/restic.nix ];

  age.secrets.restic-b2.file = ../../secrets/restic/b2.age;
  age.secrets.restic-password.file = ../../secrets/restic/password.age;
}
