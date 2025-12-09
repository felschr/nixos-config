_:

let
  mkFirefoxModuleCompat = import ./mkFirefoxModuleCompat.nix;
  mkFirefoxProfileBinModule = import ./mkFirefoxProfileBinModule.nix;

  modulePath = [
    "programs"
    "mullvad-browser"
  ];
  name = "Mullvad Browser";
  packageName = "mullvad-browser";
in
{
  imports = [
    (mkFirefoxModuleCompat {
      inherit modulePath name;
      description = "Privacy-focused browser made in a collaboration between The Tor Project and Mullvad";
      unwrappedPackageName = packageName;
      visible = true;
      platforms.linux = rec {
        vendorPath = ".mullvad";
        configPath = "${vendorPath}/mullvadbrowser";
      };
      platforms.darwin = null;
    })
    (mkFirefoxProfileBinModule {
      inherit modulePath name packageName;
      isSecure = true;
    })
  ];
}
