{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.home-manager = {
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nur.url = "github:nix-community/NUR/master";

  inputs.pre-commit-hooks = {
    url =
      # "github:Myhlamaeus/pre-commit-hooks.nix/feat/flake";
      "github:Myhlamaeus/pre-commit-hooks.nix/8d48a4cd434a6a6cc8f2603b50d2c0b2981a7c55";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, nur, pre-commit-hooks }:
    let
      overlays = {
        deconz = self: super: {
          deconz = self.qt5.callPackage ./pkgs/deconz { };
          # This is the path so that the correct python deps and versions can be used
          # with python{version}Packages.callPackage pydeconz { }
          pydeconz = ./pkgs/pydeconz;
        };
      };
      systemModule = { hostName, hardwareConfig, config }:
        ({ pkgs, ... }: {
          networking.hostName = hostName;

          # Let 'nixos-version --json' know about the Git revision
          # of this flake.
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

          nix.registry.nixpkgs.flake = nixpkgs;

          nixpkgs.overlays = [ nur.overlay overlays.deconz ];

          imports =
            [ hardwareConfig home-manager.nixosModules.home-manager config ];
        });
    in {

      nixosConfigurations.felix-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixpkgs.nixosModules.notDetected
          (systemModule {
            hostName = "felix-nixos";
            hardwareConfig = ./hardware/felix-nixos.nix;
            config = ./home-pc.nix;
          })
        ];
      };

      nixosConfigurations.pilot1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixpkgs.nixosModules.notDetected
          (systemModule {
            hostName = "pilot1";
            hardwareConfig = ./hardware-configuration.nix; # TODO
            config = ./work-pc.nix;
          })
        ];
      };

      nixosConfigurations.felix-rpi4 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixpkgs.nixosModules.notDetected
          (systemModule {
            hostName = "felix-rpi4";
            hardwareConfig = ./hardware/rpi4.nix;
            config = ./rpi4.nix;
          })
        ];
      };

      inherit overlays;

      nixosModules.deconz = import ./services/deconz.nix;

      homeManagerModules.git = import ./home/modules/git.nix;

    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pre-commit-check = pre-commit-hooks.defaultPackage.${system} {
          src = ./.;
          hooks = { nixfmt.enable = true; };
        };
      in {
        devShell = pkgs.mkShell { inherit (pre-commit-check) shellHook; };
      });
}
