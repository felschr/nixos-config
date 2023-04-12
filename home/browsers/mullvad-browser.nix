{ config, nixosConfig, pkgs, lib, ... }:

let
  inherit (pkgs.nur.repos.rycee) firefox-addons;

  commonSettings = {
    # Disable private browsing mode and restoring sessions
    "browser.privatebrowsing.autostart" = false;
    "browser.startup.page" = 3;

    # Enable persistence of site permissions
    "permissions.memory_only" = false;

    # Hide titlebar
    "browser.tabs.inTitlebar" = 1;

    # Don't delete cookies & site data on restart
    "network.cookie.lifetimePolicy" = 0;

    # Allow push notifications
    "dom.push.enabled" = true;
    "dom.push.serverURL" = "wss://push.services.mozilla.com/";
  };

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

  commonExtensions = with firefox-addons; [
    bitwarden
    vimium
    libredirect
    zotero-connector
  ];
in {
  imports = [ ../modules/mullvad-browser.nix ];

  programs.mullvad-browser = {
    enable = true;
    createProfileBins = true;
    profiles = {
      private = {
        id = 0;
        settings = commonSettings;
        extensions = commonExtensions;
      };
      work = {
        id = 1;
        settings = commonSettings;
        extensions = commonExtensions
          ++ (with firefox-addons; [ react-devtools reduxdevtools ]);
      };
    };
  };
}
