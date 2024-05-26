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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arkenfox-userjs = {
      url = "github:arkenfox/user.js";
      flake = false;
    };

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
    };

    matrix-appservices = {
      url = "gitlab:coffeetables/nix-matrix-appservices";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim-kitty-navigator = {
      url = "github:hermitmaster/nvim-kitty-navigator";
      flake = false;
    };

    openwrt-imagebuilder = {
      url = "github:astro/nix-openwrt-imagebuilder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      imports = [
        ./pkgs/flake-module.nix
        ./lib/flake-module.nix
        ./hosts/flake-module.nix
        ./overlays.nix
      ];
      flake = {
        inherit nixConfig;

        nixosModules = {
          flakeDefaults = import ./modules/flakeDefaults.nix;
          systemdNotify = import ./modules/systemdNotify.nix;
          inadyn = import ./modules/inadyn.nix;
        };

        homeManagerModules = {
          git = import ./home/modules/git.nix;
          firefox = import ./home/modules/firefox/firefox.nix;
          tor-browser = import ./home/modules/firefox/tor-browser.nix;
          mullvad-browser = import ./home/modules/firefox/mullvad-browser.nix;
        };
      };
      perSystem = { system, config, pkgs, ... }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        devShells.default =
          pkgs.mkShell { inherit (config.checks.pre-commit) shellHook; };

        checks = {
          pre-commit = inputs.pre-commit-hooks.lib.${system}.run {
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
