{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.nixpkgs-glslls.url = "github:felschr/nixpkgs/glsl-language-server";

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.home-manager = {
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nur.url = "github:nix-community/NUR/master";

  inputs.agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.pre-commit-hooks = {
    url = "github:cachix/pre-commit-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };

  inputs.nvim-kitty-navigator = {
    url = "github:hermitmaster/nvim-kitty-navigator";
    flake = false;
  };

  outputs = { self, nixpkgs, nixos-hardware, flake-utils, home-manager, nur
    , agenix, pre-commit-hooks, nvim-kitty-navigator, nixpkgs-glslls }@inputs:
    let
      overlays = {
        neovim = self: super:
          let
            buildVimPlugin = name: input:
              super.pkgs.vimUtils.buildVimPluginFrom2Nix {
                pname = name;
                version = input.rev;
                versionSuffix = "-git";
                src = input;
              };
          in {
            vimPlugins = super.vimPlugins // {
              nvim-kitty-navigator =
                buildVimPlugin "nvim-kitty-navigator" nvim-kitty-navigator;
            };
          };
        deconz = self: super: {
          deconz = self.qt5.callPackage ./pkgs/deconz { };
        };
        glslls = self: super: {
          glsl-language-server =
            nixpkgs-glslls.legacyPackages.${self.system}.glsl-language-server;
        };
      };
      nixosModules = {
        flakeDefaults = import ./modules/flakeDefaults.nix;
        emailNotify = import ./modules/emailNotify.nix;
      };
      homeManagerModules = { git = import ./home/modules/git.nix; };
      systemDefaults = {
        modules = [ nixosModules.flakeDefaults agenix.nixosModule ];
        overlays = with overlays; [ nur.overlay neovim deconz glslls ];
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

      nixosConfigurations.home-pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixpkgs.nixosModules.notDetected
          (lib.createSystem "home-pc" {
            hardwareConfig = ./hardware/home-pc.nix;
            config = ./home-pc.nix;
          })
          (lib.createUser "felschr" {
            user.extraGroups = [ "wheel" "audio" "docker" "disk" ];
            modules = [ homeManagerModules.git ];
            config = ./home/felschr.nix;
          })
          ({ config, pkgs, ... }: {
            age.secrets = {
              restic-b2.file = ./secrets/restic/b2.age;
              restic-password.file = ./secrets/restic/password.age;
              samba.file = ./secrets/samba.age;
              smtp.file = ./secrets/smtp.age;
            };
            environment.systemPackages = with pkgs;
              [ agenix.defaultPackage.x86_64-linux ];
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
          (lib.createSystem "felix-rpi4" {
            hardwareConfig = ./hardware/rpi4.nix;
            config = ./rpi4.nix;
          })
          (lib.createUser "felschr" {
            user = {
              extraGroups = [ "wheel" "audio" "disk" "media" ];
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP751vlJUnB7Pfe1KNr6weWkx/rkP4J3lTYpAekHdOgV"
              ];
            };
            modules = [ homeManagerModules.git ];
            config = ./home/felschr-rpi4.nix;
          })
          ({ config, pkgs, ... }: {
            age.secrets = {
              hostKey.file = ./secrets/home-server/hostKey.age;
              cfdyndns.file = ./secrets/cfdyndns.age;
              restic-b2.file = ./secrets/restic/b2.age;
              restic-password.file = ./secrets/restic/password.age;
              # samba.file = ./secrets/samba.age;
              smtp.file = ./secrets/smtp.age;
              mqtt-felix.file = ./secrets/mqtt/felix.age;
              mqtt-birgit.file = ./secrets/mqtt/birgit.age;
              mqtt-hass.file = ./secrets/mqtt/hass.age;
              mqtt-tasmota.file = ./secrets/mqtt/tasmota.age;
              mqtt-owntracks.file = ./secrets/mqtt/owntracks.age;
              mqtt-owntracks-plain.file = ./secrets/mqtt/owntracks-plain.age;
              owntracks-htpasswd.file = ./secrets/owntracks/htpasswd.age;
              etebase-server.file = ./secrets/etebase-server.age;
              miniflux.file = ./secrets/miniflux.age;
              paperless.file = ./secrets/paperless.age;
              nextcloud-admin.file = ./secrets/nextcloud/admin.age;
            };
            environment.systemPackages = with pkgs;
              [ agenix.defaultPackage.x86_64-linux ];
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
