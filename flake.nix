{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.home-manager = {
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nur.url = "github:nix-community/NUR/master";

  inputs.neovim = {
    url = "github:neovim/neovim?dir=contrib";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };

  inputs.obelisk = {
    url = "github:obsidiansystems/obelisk";
    flake = false;
  };

  inputs.photoprism-flake = {
    url = "github:GTrunSec/photoprism-flake";
    inputs.flake-utils.follows = "flake-utils";
  };

  inputs.pre-commit-hooks = {
    url = "github:cachix/pre-commit-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };

  inputs.nvim-ts-autotag = {
    url = "github:windwp/nvim-ts-autotag";
    flake = false;
  };

  inputs.nvim-ts-context-commentstring = {
    url = "github:JoosepAlviste/nvim-ts-context-commentstring";
    flake = false;
  };

  outputs = { self, nixpkgs, nixos-hardware, flake-utils, home-manager, nur
    , neovim, obelisk, photoprism-flake, pre-commit-hooks, nvim-ts-autotag
    , nvim-ts-context-commentstring }@inputs:
    let
      overlays = {
        neovim = self: super:
          with super.pkgs.vimUtils; {
            neovim-nightly = neovim.packages.${self.system}.neovim;
            vimPlugins = super.vimPlugins // {
              nvim-ts-autotag = buildVimPluginFrom2Nix {
                pname = "nvim-ts-autotag";
                version = nvim-ts-autotag.rev;
                versionSuffix = "-git";
                src = nvim-ts-autotag;
              };
              nvim-ts-context-commentstring = buildVimPluginFrom2Nix {
                pname = "nvim-ts-context-commentstring";
                version = nvim-ts-context-commentstring.rev;
                versionSuffix = "-git";
                src = nvim-ts-context-commentstring;
              };
            };
          };
        deconz = self: super: {
          deconz = self.qt5.callPackage ./pkgs/deconz { };
        };
        pop-shell = self: super: {
          pop-shell = self.callPackage ./pkgs/pop-shell { };
        };
        obelisk = self: super: {
          obelisk = (import obelisk { inherit (self) system; }).command;
        };
        # custom overlay so it's using the flake's nixpkgs
        photoprism = self: super: {
          photoprism = photoprism-flake.defaultPackage.${self.system};
        };
      };
      nixosModules = { flakeDefaults = import ./modules/flakeDefaults.nix; };
      homeManagerModules = { git = import ./home/modules/git.nix; };
      systemDefaults = {
        modules = [ nixosModules.flakeDefaults ];
        overlays = [
          nur.overlay
          overlays.neovim
          overlays.deconz
          overlays.pop-shell
          overlays.photoprism
          overlays.obelisk
        ];
      };
      lib = rec {
        createSystem = hostName:
          { hardwareConfig, config }:
          ({ pkgs, lib, ... }: {
            networking.hostName = hostName;

            nixpkgs.overlays = systemDefaults.overlays;

            imports = systemDefaults.modules ++ [
              hardwareConfig
              config
              {
                # make arguments available to modules
                _module.args = { inherit self inputs; };
              }
            ];
          });
        createUser' = import ./lib/createUser.nix;
        createUser = name: args:
          ({ pkgs, ... }@args2:
            (createUser' name args) ({ inherit home-manager; } // args2));
      };
    in rec {

      inherit lib overlays nixosModules homeManagerModules;

      nixosConfigurations.felix-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixpkgs.nixosModules.notDetected
          (lib.createSystem "felix-nixos" {
            hardwareConfig = ./hardware/felix-nixos.nix;
            config = ./home-pc.nix;
          })
          (lib.createUser "felschr" {
            user.extraGroups = [ "wheel" "audio" "docker" "disk" ];
            modules = [ homeManagerModules.git ];
            config = ./home/felschr.nix;
          })
        ];
      };

      nixosConfigurations.pilot1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixpkgs.nixosModules.notDetected
          (lib.createSystem "pilot1" {
            hardwareConfig = ./hardware/pilot1.nix;
            config = ./work-pc.nix;
          })
          (lib.createUser "felschr" {
            user.extraGroups = [ "wheel" "audio" "docker" "disk" ];
            modules = [ homeManagerModules.git ];
            config = ./home/felschr-work.nix;
          })
        ];
      };

      nixosConfigurations.felix-rpi4 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixpkgs.nixosModules.notDetected
          nixos-hardware.nixosModules.raspberry-pi-4
          # photoprism-flake.nixosModules.photoprism
          (lib.createSystem "felix-rpi4" {
            hardwareConfig = ./hardware/rpi4.nix;
            config = ./rpi4.nix;
          })
          (lib.createUser "felschr" {
            user = {
              extraGroups = [ "wheel" "audio" "disk" "media" ];
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINDTp/k2m9yUn8NGDpCzyX2iK9lOwe6lJR5sk19apxC openpgp:0xBBA675EA"
              ];
            };
            modules = [ homeManagerModules.git ];
            config = ./home/felschr-rpi4.nix;
          })
        ];
      };

    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = { nixfmt.enable = true; };
        };
      in {
        devShell = pkgs.mkShell { inherit (pre-commit-check) shellHook; };
      });
}
