{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.flakeDefaults
    inputs.agenix.nixosModules.default
  ];

  nixpkgs.overlays = [ inputs.self.overlays.default ];

  environment.systemPackages = [ inputs.agenix.packages.x86_64-linux.default ];
}
