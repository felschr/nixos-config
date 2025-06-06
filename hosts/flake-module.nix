{ self, inputs, ... }:
{
  flake = {
    diskoConfigurations = {
      cmdframe = import ./cmdframe/disk-config.nix;
    };
    nixosConfigurations = {
      home-pc = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.nixpkgs.nixosModules.notDetected
          inputs.nixos-hardware.nixosModules.common-pc
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
          inputs.nixos-hardware.nixosModules.common-gpu-amd
          (self.lib.createSystemModule "home-pc" {
            hardwareConfig = ../hardware/home-pc.nix;
            config = ../hosts/home-pc/default.nix;
          })
          self.lib.createMediaGroup
          (self.lib.createUserModule "felschr" {
            homeModule = self.homeModules.felschr;
            user.extraGroups = [
              "wheel"
              "networkmanager"
              "audio"
              "disk"
              "libvirtd"
              "qemu-libvirtd"
              "gamemode"
              "media"
            ];
            usesContainers = true;
          })
          (
            { pkgs, ... }:
            {
              environment.systemPackages = [ inputs.deploy-rs.packages.x86_64-linux.default ];
            }
          )
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
          inputs.nixos-hardware.nixosModules.common-cpu-intel
          inputs.nixos-hardware.nixosModules.common-gpu-intel-kaby-lake
          inputs.matrix-appservices.nixosModule
          (self.lib.createSystemModule "home-server" {
            hardwareConfig = ../hardware/lattepanda.nix;
            config = ../hosts/home-server/default.nix;
          })
          self.lib.createMediaGroup
          (self.lib.createUserModule "felschr" {
            homeModule = self.homeModules.felschr-server;
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
          })
        ];
        specialArgs = {
          inherit inputs;
        };
      };
      cmdframe = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.disko.nixosModules.disko
          inputs.nixpkgs.nixosModules.notDetected
          inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
          (self.lib.createSystemModule "cmdframe" {
            hardwareConfig = ../hosts/cmdframe/hardware.nix;
            config = ../hosts/cmdframe/default.nix;
          })
          (self.lib.createUserModule "felschr" {
            homeModule = self.homeModules.felschr-work;
            user.extraGroups = [
              "wheel"
              "networkmanager"
              "audio"
              "disk"
              "libvirtd"
              "qemu-libvirtd"
            ];
            usesContainers = true;
          })
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };

    deploy.nodes.home-server = {
      hostname = "home-server";
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
