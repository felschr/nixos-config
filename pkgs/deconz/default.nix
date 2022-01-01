{ lib, fetchurl, mkDerivation, dpkg, autoPatchelfHook, qtserialport
, qtwebsockets, libredirect, makeWrapper, gzip, gnutar }:

mkDerivation rec {
  name = "deconz-${version}";
  version = "2.09.03";

  src = fetchurl {
    url =
      "https://deconz.dresden-elektronik.de/debian/stable/deconz_${version}-debian-stretch-stable_arm64.deb";
    sha256 = "6EXYoXOg+6dTR9/hRHmNafZuBeNnAAS4z8ia15s1+9U=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  buildInputs = [ qtserialport qtwebsockets ];

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
    platforms = with platforms; linux;
    maintainers = with maintainers; [ felschr ];
  };
}
