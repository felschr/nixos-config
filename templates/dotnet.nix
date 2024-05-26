{ config, pkgs, ... }:

with pkgs;
let
  dotnet-combined = with dotnetCorePackages; combinePackages [ sdk_3_1 ];
  dotnetRoot = "${dotnet-combined}";
  dotnetSdk = "${dotnet-combined}/sdk";
  dotnetBinary = "${dotnetRoot}/bin/dotnet";
in
{
  home.packages = [ dotnet-combined ];

  home.sessionVariables = {
    DOTNET_ROOT = dotnetRoot;
    MSBuildSdksPath = "${dotnetSdk}/$(${dotnetBinary} --version)/Sdks";
    MSBUILD_EXE_PATH = "${dotnetSdk}/$(${dotnetBinary} --version)/MSBuild.dll";
  };
}
