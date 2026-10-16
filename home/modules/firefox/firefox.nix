_:

let
  mkFirefoxProfileBinModule = import ./mkFirefoxProfileBinModule.nix;

  modulePath = [
    "programs"
    "firefox"
  ];
  name = "Firefox";
  packageName = "firefox";
in
{
  imports = [
    (mkFirefoxProfileBinModule {
      inherit modulePath name packageName;
      isSecure = true;
    })
    (import ./site-data-exceptions.nix {
      inherit modulePath name packageName;
    })
  ];
}
