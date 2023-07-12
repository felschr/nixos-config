{ pkgs, lib, inputs, ... }:

let
  flakes = lib.filterAttrs (name: value: value ? outputs) inputs;
  nixRegistry = builtins.mapAttrs (name: v: { flake = v; }) flakes;
in {
  # Let 'nixos-version --json' know about the Git revision
  # of this flake.
  system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    nixPath = lib.mapAttrsToList (n: v: "${n}=${v}") flakes;
    registry = nixRegistry;
  };
}
