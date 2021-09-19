{ lib, fetchFromGitHub, stdenv, glib, nodePackages, gjs }:

stdenv.mkDerivation rec {
  pname = "pop-shell";
  version = "2021-09-10";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "shell";
    rev = "59ca9cede3c185c347bd2ae3d40882e020fb1fd0";
    sha256 = "llwchrg/a8QmmD9eOt7IUZY2crYubFSDyvrTVwSz0pE=";
  };

  nativeBuildInputs = [ glib nodePackages.typescript gjs ];

  buildInputs = [ gjs ];

  # the gschema doesn't seem to be installed properly (see dconf)
  makeFlags = [
    "INSTALLBASE=$(out)/share/gnome-shell/extensions"
    "PLUGIN_BASE=$(out)/share/pop-shell/launcher"
    "SCRIPTS_BASE=$(out)/share/pop-shell/scripts"
  ];
}
