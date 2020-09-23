{ config, pkgs, ... }:

with pkgs;
let
  # preview
  # buildDotnet = attrs: callPackage (import <nixpkgs/pkgs/development/compilers/dotnet/build-dotnet.nix> attrs) {};
  # buildAspNetCore = attrs: buildDotnet (attrs // { type = "aspnetcore"; });
  # buildNetCore = attrs: buildDotnet (attrs // { type = "netcore"; });
  # buildNetCoreSdk = attrs: buildDotnet (attrs // { type = "sdk"; });

  # sdk_5_0_rc_1 = buildNetCoreSdk {
  #   version = "5.0.100-rc.1.20452.10";
  #   sha512 = {
  #     x86_64-linux = "d7e709dacc4bb188c2380060d24bfb5b791240dc33af8499fb4a31e1885a9377dad1d1ebc76847432ea67d5e4ac832a31679dc293e09fa6dade28f5fbbe4db9b";
  #     aarch64-linux = "2d04890c71e845d1eb08f5dfbbb9c93024d7a52fb1cc3fd50bd51bc6bd44e455c5c82abc8f04eef23bd012984ae5f86143c600ceb49c4c733935d95d5b68785f";
  #     x86_64-darwin = "06bb40273071f3dd1e84ebf58abc7798795d5f1ac298f24bf7109d1597fd52ff31bcbf2b81f86d91d37ae293678d07f8da0469d7cbd318d19a8d718b6629dcac";
  #   };
  # };

  dotnet-combined = with dotnetCorePackages; combinePackages [ sdk_3_1 ];
  dotnetRoot = "${dotnet-combined}";
  dotnetSdk = "${dotnet-combined}/sdk";
  dotnetBinary = "${dotnetRoot}/bin/dotnet";
in {
  home.packages = [ dotnet-combined ];

  home.sessionVariables = {
    DOTNET_ROOT = dotnetRoot;
    MSBuildSdksPath = "${dotnetSdk}/$(${dotnetBinary} --version)/Sdks";
    MSBUILD_EXE_PATH = "${dotnetSdk}/$(${dotnetBinary} --version)/MSBuild.dll";
  };
}
