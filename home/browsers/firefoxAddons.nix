{ pkgs, lib, ... }:

let inherit (pkgs.nur.repos.rycee) firefox-addons;
in {
  zotero-connector = firefox-addons.buildFirefoxXpiAddon rec {
    pname = "zotero-connector";
    version = "5.0.107";
    addonId = "zotero@chnm.gmu.edu";
    url =
      "https://download.zotero.org/connector/firefox/release/Zotero_Connector-${version}.xpi";
    sha256 = "sha256-RuAhWGvUhkog8SxzKhRwQQwzTQLzBKlHjSsFj9e25e4=";
    meta = with lib; {
      homepage = "https://www.zotero.org";
      description = "Save references to Zotero from your web browser";
      license = licenses.agpl3;
      platforms = platforms.all;
    };
  };
}
