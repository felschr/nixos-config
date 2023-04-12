{ config, nixosConfig, pkgs, lib, ... }:

let
  firefox-addons = pkgs.nur.repos.rycee.firefox-addons
    // (import ./firefoxAddons.nix { inherit pkgs lib; });

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
