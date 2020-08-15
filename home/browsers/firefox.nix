{ config, pkgs, lib, ... }:

with lib;
let
  firefox-addons = pkgs.nur.repos.rycee.firefox-addons;

  prefer-dark-theme = config.gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme;

  sharedSettings = {
    # Privacy recommendations from https://www.privacytools.io/browsers/#about_config
    "privacy.firstparty.isolate" = true;
    "privacy.resistFingerprinting" = true;
    "privacy.trackingprotection.fingerprinting.enabled" = true;
    "privacy.trackingprotection.cryptomining.enabled" = true;
    "privacy.trackingprotection.socialtracking.enabled" = true;
    "privacy.trackingprotection.enabled" = true;
    "browser.send_pings" = false;
    "browser.urlbar.speculativeConnect.enabled" = false;
    "dom.event.clipboardevents.enabled" = false;
    "media.eme.enabled" = false;
    "media.gmp-widevinecdm.enabled" = false;
    "media.navigator.enabled" = false;
    "network.cookie.cookieBehavior" = 1;
    "network.http.referer.XOriginPolicy" = 2;
    "network.http.referer.XOriginTrimmingPolicy" = 2;
    "webgl.disabled" = true;
    "browser.sessionstore.privacy_level" = 2;
    "network.IDN_show_punycode" = true;

    # Theme
    "extensions.activeThemeID" = concatStrings
      [ "firefox-compact-"
        (if prefer-dark-theme then "dark" else "light")
        "@mozilla.org"
      ];
    "devtools.theme" = if prefer-dark-theme
      then "dark"
      else "light";
  };
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      cfg = {
        enableFXCastBridge = true;
      };
    };
    profiles = {
      private = {
        id = 0;
        settings = sharedSettings;
      };
      work = {
        id = 1;
        settings = sharedSettings;
      };
    };
    extensions = with firefox-addons; [
      https-everywhere
      ublock-origin
      decentraleyes
      vimium
      ipfs-companion
      firefox-addons."1password-x-password-manager"
      darkreader
      # languagetool # not available :/
      # fx_cast # TODO not published yet
    ];
  };
}
