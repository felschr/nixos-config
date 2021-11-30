{ lib, fetchFromGitHub, stdenv, glib, nodePackages, gjs }:

stdenv.mkDerivation rec {
  pname = "pop-shell";
  version = "2021-10-26";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "shell";
    rev = "4b65ee865d01436ec75a239a0586a2fa6051b8c3";
    sha256 = "DHmp3kzBgbyxRe0TjER/CAqyUmD9LeRqAFQ9apQDzfk=";
  };

  nativeBuildInputs = [ glib nodePackages.typescript gjs ];

  buildInputs = [ gjs ];

  preBuildHook = ''
    find . -name '*.ts' -exec sed -i -E 's|^#!/usr/bin/gjs|#!/usr/bin/env gjs|' \{\} \;
    find . -name '*.ts' -exec sed -i -E 's|\["gjs", path]|[path]|' \{\} \;
    find . -name '*.ts' -exec sed -i -E 's|`gjs $\{path}`|path|' \{\} \;
  '';

  # the gschema doesn't seem to be installed properly (see dconf)
  makeFlags = [
    "INSTALLBASE=$(out)/share/gnome-shell/extensions"
    "PLUGIN_BASE=$(out)/share/pop-shell/launcher"
    "SCRIPTS_BASE=$(out)/share/pop-shell/scripts"
  ];

  postInstall = ''
    chmod +x $out/share/gnome-shell/extensions/pop-shell@system76.com/floating_exceptions/main.js
    chmod +x $out/share/gnome-shell/extensions/pop-shell@system76.com/color_dialog/main.js
  '';
}
