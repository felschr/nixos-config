{ stdenv, callPackage }:

{ package # pkg must contain $out/bin with executables within.
, binPath ?
  "bin/${package.meta.mainProgram or package.pname}" # path to look for binary
, wrapper # wrapper must contain @EXECUTABLE@ as a placeholder for the binary to run.
}:

# pass through all arguments to wrapped package to allow overriding
# arguments in wrapped package
callPackage (args:
  stdenv.mkDerivation {
    name = "${package.name}-wrapped";
    inherit (package) version;
    src = package.override args;
    dontUnpack = true;

    # inherit passthru
    inherit (package) passthru;

    installPhase = ''
      local executable=$out/${binPath}
      install -D ${wrapper} "$executable"
      substituteInPlace "$executable" --subst-var-by EXECUTABLE "$f"

      # Symlink the share directory so that .desktop files and such continue to work.
      if [[ -d $src/share ]]
      then
        ln -s $src/share $out/share
      fi
    '';
  }) { }
