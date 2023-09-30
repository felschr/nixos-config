{ inputs, pkgs, lib, ... }:

let
  firefox-addons = inputs.firefox-addons.packages.${pkgs.system}
    // (import ./firefoxAddons.nix { inherit inputs pkgs lib; });

  commonSettings = {
    # Disable DNS over HTTPS (use system DNS, i.e. VPN's DNS)
    "network.trr.mode" = 5;

    # Set Security Level Safer
    # "browser.security_level.security_slider" = 2;

    # Disable private browsing mode and enable restoring sessions
    "browser.privatebrowsing.autostart" = false;
    "browser.startup.page" = 3;

    # Enable persistence of site permissions
    "permissions.memory_only" = false;

    # Don't delete cookies & site data on restart
    # "network.cookie.lifetimePolicy" = 0;

    # Disable extension auto updates
    "extensions.update.enabled" = false;
    "extensions.update.autoUpdateDefault" = false;
  };

  commonExtensions = with firefox-addons; [
    german-dictionary
    bitwarden
    libredirect
    zotero-connector
  ];
in {
  imports = [ ../modules/firefox/mullvad-browser.nix ];

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
