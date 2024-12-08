{ pkgs, ... }:

{
  # Update `newPostgres` version, uncomment & run `upgrade-pg-cluster`. For details,
  # see https://nixos.org/manual/nixos/stable/#module-services-postgres-upgrading
  # imports = [ ./upgrade-pg-cluster.nix ];

  services.postgresql.package = pkgs.postgresql_16;
}
