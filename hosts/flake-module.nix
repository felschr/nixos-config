{ self, inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      home-pc = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.nixpkgs.nixosModules.notDetected
          inputs.nixos-hardware.nixosModules.common-pc
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
          inputs.nixos-hardware.nixosModules.common-gpu-amd
          (self.lib.createSystem "home-pc" {
            hardwareConfig = ../hardware/home-pc.nix;
            config = ../hosts/home-pc.nix;
          })
          self.lib.createMediaGroup
          (self.lib.createUser "felschr" {
            user.extraGroups = [
              "wheel"
              "networkmanager"
              "audio"
              "disk"
              "libvirtd"
              "qemu-libvirtd"
              "media"
            ];
            modules = [ self.homeManagerModules.git ];
            config = ../home/felschr.nix;
            usesContainers = true;
          })
          (
            { pkgs, ... }:
            {
              environment.systemPackages = [ inputs.deploy-rs.defaultPackage.x86_64-linux ];
            }
          )
        ];
        specialArgs = {
          inherit inputs;
        };
      };
      pilot1 = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.nixpkgs.nixosModules.notDetected
          inputs.nixos-hardware.nixosModules.common-pc
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          inputs.nixos-hardware.nixosModules.common-cpu-intel
          (self.lib.createSystem "pilot1" {
            hardwareConfig = ../hardware/pilot1.nix;
            config = ../hosts/work-pc.nix;
          })
          (self.lib.createUser "felschr" {
            user.extraGroups = [
              "wheel"
              "audio"
              "disk"
            ];
            modules = [ self.homeManagerModules.git ];
            config = ../home/felschr-work.nix;
            usesContainers = true;
          })
        ];
        specialArgs = {
          inherit inputs;
        };
      };
      home-server = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.nixpkgs.nixosModules.notDetected
          inputs.nixos-hardware.nixosModules.common-pc
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          inputs.nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
          inputs.matrix-appservices.nixosModule
          (self.lib.createSystem "home-server" {
            hardwareConfig = ../hardware/lattepanda.nix;
            config = ../hosts/home-server.nix;
          })
          self.lib.createMediaGroup
          (self.lib.createUser "felschr" {
            user = {
              extraGroups = [
                "wheel"
                "audio"
                "disk"
                "media"
              ];
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP751vlJUnB7Pfe1KNr6weWkx/rkP4J3lTYpAekHdOgV"
              ];
            };
            modules = [ self.homeManagerModules.git ];
            config = ../home/felschr-server.nix;
          })
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };

    deploy.nodes.home-server = {
      hostname = "192.168.1.102";
      profiles.system = {
        sshUser = "felschr";
        sshOpts = [ "-t" ];
        user = "root";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.home-server;
        magicRollback = false; # otherwise password prompt won't work
      };
    };
  };
  perSystem =
    {
      system,
      config,
      pkgs,
      ...
    }:
    {
      checks = inputs.deploy-rs.lib.${system}.deployChecks self.deploy;
    };
}
