{ inputs, pkgs, lib, ... }:

let inherit (inputs.firefox-addons.lib.${pkgs.system}) buildFirefoxXpiAddon;
in {
  german-dictionary = buildFirefoxXpiAddon rec {
    pname = "german-dictionary";
    version = "2.1";
    addonId = "de-DE@dictionaries.addons.mozilla.org";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/1163876/german_dictionary-${version}.xpi?src=";
    sha256 = "sha256-p+/vXp/fD2RgrDiVHByjdmJY2CZHrUi9h5Vb1QCc6eA=";
    meta = with lib; {
      description =
        "German Dictionary (new Orthography) for spellchecking in Mozilla products";
      license = licenses.lgpl21;
      platforms = platforms.all;
    };
  };
  zotero-connector = buildFirefoxXpiAddon rec {
    pname = "zotero-connector";
    version = "5.0.108";
    addonId = "zotero@chnm.gmu.edu";
    url =
      "https://download.zotero.org/connector/firefox/release/Zotero_Connector-${version}.xpi";
    sha256 = "sha256-Ic34T9++qZpbx8rRAhaRZfiwNClQo6iRS2RmS95v55c=";
    meta = with lib; {
      homepage = "https://www.zotero.org";
      description = "Save references to Zotero from your web browser";
      license = licenses.agpl3;
      platforms = platforms.all;
    };
  };
  ddg-bangs-but-faster = buildFirefoxXpiAddon rec {
    pname = "ddg-bangs-but-faster";
    version = "0.2.2";
    addonId = "{55bf0dfc-ebd5-4705-a68d-61c6ac6ecad0}";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/3743190/ddg_bangs_but_faster-${version}.xpi";
    sha256 = "sha256-O8jvzxXH83JKydxUYUpKY/rB2s4BpG8a3gnoYgL4vLA=";
    meta = with lib; {
      homepage = "https://bangs-but-faster.inclushe.com/";
      description = "Processes DuckDuckGo !bangs client-side";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
}
