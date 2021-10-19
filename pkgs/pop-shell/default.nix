{ lib, fetchFromGitHub, stdenv, glib, nodePackages, gjs }:

stdenv.mkDerivation rec {
  pname = "pop-shell";
  version = "2021-10-18";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "shell";
    rev = "1de4139c5739ff79d7a3ddef7a9a77988a358782";
    sha256 = "094siblqpsjj356s32dn3rqq0vd47xrmbklzzyx26nh4hxlvzkzb";
  };

  nativeBuildInputs = [ glib nodePackages.typescript gjs ];

  buildInputs = [ gjs ];

  preBuildHook = ''
    ./fix-gjs.patch
    find . -name '*.ts' -exec sed -i -E 's|^#!/usr/bin/gjs|#!/usr/bin/env gjs|' \{\} \;
    (fetchpatch {
  '';

  patches = [ ./gnome-41.patch ];

  # the gschema doesn't seem to be installed properly (see dconf)
  makeFlags = [
    "INSTALLBASE=$(out)/share/gnome-shell/extensions"
    "PLUGIN_BASE=$(out)/share/pop-shell/launcher"
    "SCRIPTS_BASE=$(out)/share/pop-shell/scripts"
  ];

  postInstall = ''
    chmod +x $out/share/gnome-shell/extensions/pop-shell@system76.com/floating_exceptions/main.js
    chmod +x $out/share/gnome-shell/extensions/pop-shell@system76.com/floating_exceptions/main.js
    chmod +x $out/share/gnome-shell/extensions/pop-shell@system76.com/color_dialog/main.js
    chmod +x $out/share/gnome-shell/extensions/pop-shell@system76.com/color_dialog/main.js
    rm -rf $out/bin
    rm -rf $out/bin
  '';
}
