{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR/master";

    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    conduit = {
      url = "gitlab:famedly/conduit";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-utils.follows = "flake-utils";
    };

    matrix-appservices = {
      url = "gitlab:coffeetables/nix-matrix-appservices";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim-kitty-navigator = {
      url = "github:hermitmaster/nvim-kitty-navigator";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, flake-parts
    , flake-utils, home-manager, nur, agenix, deploy-rs, pre-commit-hooks
    , nvim-kitty-navigator, ... }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      imports = [ ];
      flake = rec {
        lib = rec {
          createSystem = hostName:
            { hardwareConfig, config }:
            ({ pkgs, lib, ... }: {
              networking.hostName = hostName;

              nixpkgs.overlays = [ nur.overlay self.overlays.default ];

              imports = [
                nixosModules.flakeDefaults
                agenix.nixosModules.default
                inputs.matrix-appservices.nixosModule
                hardwareConfig
                config
              ];

              environment.systemPackages =
                [ agenix.packages.x86_64-linux.default ];
            });
          createUser' = import ./lib/createUser.nix;
          createUser = name: args:
            ({ pkgs, ... }@args2:
              (createUser' name args) ({ inherit home-manager; } // args2));
          createMediaGroup = _: { users.groups.media.gid = 600; };
        };

        overlays.default = final: prev: {
          unstable = import nixpkgs-unstable {
            inherit (prev) system;
            config.allowUnfree = true;
          };
          inherit (self.packages.${prev.system}) deconz;
          vimPlugins = prev.vimPlugins
            // final.callPackage ./pkgs/vim-plugins { inherit inputs; };
        };

        nixosModules = {
          flakeDefaults = import ./modules/flakeDefaults.nix;
          systemdNotify = import ./modules/systemdNotify.nix;
        };

        homeManagerModules = {
          git = import ./home/modules/git.nix;
          firefox = import ./home/modules/firefox/firefox.nix;
          tor-browser = import ./home/modules/firefox/tor-browser.nix;
        };

        nixosConfigurations = {
          home-pc = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              nixpkgs.nixosModules.notDetected
              nixos-hardware.nixosModules.common-pc
              nixos-hardware.nixosModules.common-pc-ssd
              nixos-hardware.nixosModules.common-cpu-amd-pstate
              nixos-hardware.nixosModules.common-gpu-amd
              (lib.createSystem "home-pc" {
                hardwareConfig = ./hardware/home-pc.nix;
                config = ./home-pc.nix;
              })
              lib.createMediaGroup
              (lib.createUser "felschr" {
                user.extraGroups = [ "wheel" "audio" "disk" "media" ];
                modules = [ homeManagerModules.git ];
                config = ./home/felschr.nix;
              })
              ({ pkgs, ... }: {
                environment.systemPackages =
                  [ deploy-rs.defaultPackage.x86_64-linux ];
              })
            ];
            specialArgs = { inherit inputs; };
          };
          pilot1 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              nixpkgs.nixosModules.notDetected
              nixos-hardware.nixosModules.common-pc
              nixos-hardware.nixosModules.common-pc-ssd
              nixos-hardware.nixosModules.common-cpu-intel
              (lib.createSystem "pilot1" {
                hardwareConfig = ./hardware/pilot1.nix;
                config = ./work-pc.nix;
              })
              (lib.createUser "felschr" {
                user.extraGroups = [ "wheel" "audio" "disk" ];
                modules = [ homeManagerModules.git ];
                config = ./home/felschr-work.nix;
              })
            ];
            specialArgs = { inherit inputs; };
          };
          home-server = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              nixpkgs.nixosModules.notDetected
              nixos-hardware.nixosModules.common-pc
              nixos-hardware.nixosModules.common-pc-ssd
              nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
              (lib.createSystem "home-server" {
                hardwareConfig = ./hardware/lattepanda.nix;
                config = ./home-server.nix;
              })
              lib.createMediaGroup
              (lib.createUser "felschr" {
                user = {
                  extraGroups = [ "wheel" "audio" "disk" "media" ];
                  openssh.authorizedKeys.keys = [
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP751vlJUnB7Pfe1KNr6weWkx/rkP4J3lTYpAekHdOgV"
                  ];
                };
                modules = [ homeManagerModules.git ];
                config = ./home/felschr-server.nix;
              })
            ];
            specialArgs = { inherit inputs; };
          };
        };

        deploy.nodes.home-server = {
          hostname = "192.168.1.102";
          profiles.system = {
            sshUser = "felschr";
            sshOpts = [ "-t" ];
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.home-server;
            magicRollback = false; # otherwise password prompt won't work
          };
        };
      };
      perSystem = { system, config, pkgs, ... }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        packages = import ./pkgs { inherit pkgs; };

        apps = {
          deconz = flake-utils.lib.mkApp { drv = config.packages.deconz; };
        };

        devShells.default =
          pkgs.mkShell { inherit (config.checks.pre-commit) shellHook; };

        checks = deploy-rs.lib.${system}.deployChecks self.deploy // {
          pre-commit = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt.enable = true;
              shellcheck.enable = true;
            };
          };
        };

        formatter = pkgs.nixfmt;
      };
    };
}
