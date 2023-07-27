{ lib, stdenv, fetchurl, mkDerivation, dpkg, autoPatchelfHook, libxcrypt-legacy
, qtserialport, qtwebsockets, libredirect, makeWrapper, gzip, gnutar }:

let
  version = "2.17.01";
  srcs = {
    x86_64-linux = fetchurl {
      url =
        "https://deconz.dresden-elektronik.de/ubuntu/beta/deconz-${version}-qt5.deb";
      sha256 = "sha256-c2G3oOnSXlivO9KXRBZIe2DEuq7vPVlNDKF6T/pZLps=";
    };

    aarch64-linux = fetchurl {
      url =
        "https://deconz.dresden-elektronik.de/debian/stable/deconz_${version}-debian-buster-stable_arm64.deb";
      sha256 = "sha256-zuy4e9bzcRqDeXP6mfzZLCDK/3we25LH6xktnO6HXps=";
    };
  };

in mkDerivation {
  pname = "deCONZ";
  inherit version;

  src = srcs.${stdenv.hostPlatform.system};

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  buildInputs = [ libxcrypt-legacy qtserialport qtwebsockets ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p "$out"
    cp -r usr/* .
    cp -r share/deCONZ/plugins/* lib/
    cp -r . $out

    wrapProgram "$out/bin/deCONZ" \
        --set LD_PRELOAD "${libredirect}/lib/libredirect.so" \
        --set NIX_REDIRECTS "/usr/share=$out/share:/usr/bin=$out/bin" \
        --prefix PATH : "${lib.makeBinPath [ gzip gnutar ]}"
  '';

  meta = with lib; {
    description =
      "Manage ZigBee network with ConBee, ConBee II or RaspBee hardware";
    # 2019-08-19: The homepage links to old software that doesn't even work --
    # it fails to detect ConBee2.
    homepage =
      "https://www.dresden-elektronik.de/funktechnik/products/software/pc-software/deconz/?L=1";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ felschr ];
  };
}
