rec {
  description = "felschr's NixOS configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://wurzelpfropf.cachix.org" # ragenix
      "https://felschr.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "wurzelpfropf.cachix.org-1:ilZwK5a6wJqVr7Fyrzp4blIEkGK+LJT0QrpWr1qBNq0="
      "felschr.cachix.org-1:raomy5XA2tsVkBoG6wo70ARIn+V24IXhWaSe3QZo12A="
    ];
  };

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2305.tar.gz";

    nixpkgs-unstable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.tar.gz";

    nixos-hardware.url =
      "https://flakehub.com/f/NixOS/nixos-hardware/0.1.tar.gz";

    fh = {
      url = "https://flakehub.com/f/DeterminateSystems/fh/0.1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    flake-utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.tar.gz";

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

    matrix-appservices = {
      url = "gitlab:coffeetables/nix-matrix-appservices";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim-kitty-navigator = {
      url = "github:hermitmaster/nvim-kitty-navigator";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, fh, flake-parts
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
          inherit (fh.packages.${prev.system}) fh;
          inherit (self.packages.${prev.system}) deconz brlaser;
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
          mullvad-browser = import ./home/modules/firefox/mullvad-browser.nix;
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
                config = ./hosts/home-pc.nix;
              })
              lib.createMediaGroup
              (lib.createUser "felschr" {
                user.extraGroups = [ "wheel" "audio" "disk" "media" ];
                modules = [ homeManagerModules.git ];
                config = ./home/felschr.nix;
                usesContainers = true;
              })
              ({ pkgs, ... }: {
                environment.systemPackages =
                  [ deploy-rs.defaultPackage.x86_64-linux ];
              })
            ];
            specialArgs = { inherit inputs nixConfig; };
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
                config = ./hosts/work-pc.nix;
              })
              (lib.createUser "felschr" {
                user.extraGroups = [ "wheel" "audio" "disk" ];
                modules = [ homeManagerModules.git ];
                config = ./home/felschr-work.nix;
                usesContainers = true;
              })
            ];
            specialArgs = { inherit inputs nixConfig; };
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
                config = ./hosts/home-server.nix;
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
            specialArgs = { inherit inputs nixConfig; };
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
