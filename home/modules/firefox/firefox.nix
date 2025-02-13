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
  ];
}
