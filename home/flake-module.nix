{
  self,
  inputs,
  pkgs,
  ...
}:

let
  createHomeConfig =
    name: args:
    inputs.home-manager.lib.homeManagerConfiguration (
      {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
      }
      // args
    );
in
{
  flake = {
    homeModules = {
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
      felschr = createHomeConfig {
        modules = [
          self.homeModules.git
          self.homeModules.felschr
        ];
      };
      felschr-server = createHomeConfig {
        modules = [
          self.homeModules.git
          self.homeModules.felschr-server
        ];
      };
      felschr-work = createHomeConfig {
        modules = [
          self.homeModules.git
          self.homeModules.felschr-work
        ];
      };
    };
    # HINT alias for deprecated output
    homeManagerModules = self.homeModules;
  };
}
