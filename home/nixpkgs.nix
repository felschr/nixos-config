# HINT nixpkgs is the global pkgs: hosts use `home-manager.useGlobalPkgs`,
# standalone homeConfigurations use `pkgsFor` — both already set allowUnfree
_:

{
  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';
}
