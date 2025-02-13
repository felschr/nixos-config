{
  inputs,
  pkgs,
  lib,
  ...
}:

let
  firefox-addons = inputs.firefox-addons.packages.${pkgs.system};

  commonSettings = {
    # Disable DNS over HTTPS (use system DNS, i.e. VPN's DNS)
    "network.trr.mode" = 5;

    # Set Security Level Safer
    # "browser.security_level.security_slider" = 2;

    # Disable private browsing mode and enable restoring sessions
    "browser.privatebrowsing.autostart" = false;
    "browser.startup.page" = 3;

    # Enable persistence of site data
    "permissions.memory_only" = false;

    # Customise clear on shutdown
    "privacy.clearOnShutdown.cache" = true;
    "privacy.clearOnShutdown.cookies" = true;
    "privacy.clearOnShutdown.sessions" = true;
    "privacy.clearOnShutdown.offlineApps" = true;
    "privacy.clearOnShutdown.openWindows" = false;
    "privacy.clearOnShutdown.siteSettings" = false;
    "privacy.clearOnShutdown.downloads" = false;
    "privacy.clearOnShutdown.formdata" = false;
    "privacy.clearOnShutdown.history" = false;

    # Disable extension auto updates
    "extensions.update.enabled" = false;
    "extensions.update.autoUpdateDefault" = false;

    # Use native file picker instead of GTK file picker
    "widget.use-xdg-desktop-portal.file-picker" = 1;

    # enable WebAuthn
    "security.webauth.webauthn" = true;

    # video acceleration
    "media.ffmpeg.vaapi.enabled" = true;
  };

  commonExtensions = with firefox-addons; [
    dictionary-german
    proton-pass
    libredirect
    zotero-connector
  ];
in
{
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
        extensions =
          commonExtensions
          ++ (with firefox-addons; [
            bitwarden
            react-devtools
            reduxdevtools
          ]);
      };
    };
  };
}
