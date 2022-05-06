{ config, pkgs, lib, ... }:

{
  age.secrets.restic-b2.file = ../../secrets/restic/b2.age;
  age.secrets.restic-password.file = ../../secrets/restic/password.age;
}
