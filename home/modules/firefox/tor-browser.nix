_:

let
  mkFirefoxModuleCompat = import ./mkFirefoxModuleCompat.nix;
  mkFirefoxProfileBinModule = import ./mkFirefoxProfileBinModule.nix;

  modulePath = [
    "programs"
    "tor-browser"
  ];
  name = "Tor Browser";
  packageName = "tor-browser";
in
{
  imports = [
    (mkFirefoxModuleCompat {
      inherit modulePath name;
      description = "Privacy-focused browser routing traffic through the Tor network";
      unwrappedPackageName = packageName;
      visible = true;
      platforms.linux = rec {
        vendorPath = ".tor project";
        configPath = "${vendorPath}/firefox";
      };
      platforms.darwin = null;
    })
    (mkFirefoxProfileBinModule {
      inherit modulePath name packageName;
      isSecure = true;
    })
  ];
}
