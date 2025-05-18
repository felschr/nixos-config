{
  self,
  inputs,
  lib,
  ...
}:

let
  mkHomeConfiguration =
    {
      user,
      system,
      modules,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = self.pkgsFor system;
      extraSpecialArgs = { inherit inputs; };

      modules =
        (with self.homeModules; [ nixpkgs ])
        ++ [
          {
            home.username = user;
            home.homeDirectory = "/home/${user}";
          }
        ]
        ++ modules;
    };
in
{
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  flake = {
    homeModules = {
      nixpkgs = import ./modules/nixpkgs.nix;
      git = import ./modules/git.nix;
      firefox = import ./modules/firefox/firefox.nix;
      tor-browser = import ./modules/firefox/tor-browser.nix;
      mullvad-browser = import ./modules/firefox/mullvad-browser.nix;

      # users
      felschr = import ./felschr.nix;
      felschr-server = import ./felschr-server.nix;
      felschr-work = import ./felschr-work.nix;
    };
    homeConfigurations = {
      felschr = mkHomeConfiguration {
        user = "felschr";
        system = "x86_64-linux";
        modules = [
          self.homeModules.git
          self.homeModules.felschr
        ];
      };
      felschr-server = mkHomeConfiguration {
        user = "felschr";
        system = "x86_64-linux";
        modules = [
          self.homeModules.git
          self.homeModules.felschr-server
        ];
      };
      felschr-work = mkHomeConfiguration {
        user = "felschr";
        system = "x86_64-linux";
        modules = [
          self.homeModules.git
          self.homeModules.felschr-work
        ];
      };
    };
    homeManagerModules = lib.warn "`homeManagerModules` is deprecated. Use `homeModules` instead." self.homeModules;
  };
}
