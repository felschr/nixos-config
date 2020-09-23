{ config, pkgs, lib, ... }:

with lib;
let
  firefox-addons = pkgs.nur.repos.rycee.firefox-addons;

  prefer-dark-theme = config.gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme;

  sharedSettings = {
    # Privacy recommendations from https://www.privacytools.io/browsers/#about_config
    "privacy.firstparty.isolate" = true;
    # "privacy.resistFingerprinting" = true; # forces ui.systemUsesDarkTheme to false
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
    # "webgl.disabled" = true;
    "browser.sessionstore.privacy_level" = 2;
    "network.IDN_show_punycode" = true;

    # Theme
    "ui.systemUsesDarkTheme" = prefer-dark-theme;
    "extensions.activeThemeID" = concatStrings
      [ "firefox-compact-"
        (if prefer-dark-theme then "dark" else "light")
        "@mozilla.org"
      ];
    "devtools.theme" = if prefer-dark-theme
      then "dark"
      else "light";

    # Other
    "browser.startup.page" = 3;
    "browser.ssb.enabled" = true;
    "browser.tabs.drawInTitlebar" = true;
    "browser.aboutConfig.showWarning" = false;
    "signon.rememberSignons" = false;
    "services.sync.engine.passwords" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
    "browser.newtabpage.activity-stream.feeds.snippets" = false;
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
      clearurls
      terms-of-service-didnt-read
      vimium
      ipfs-companion
      bitwarden
      darkreader
      # not available yet:
      # languagetool
      # fx_cast
      # google-lighthouse
    ];
  };

  home.packages = let
    escapeDesktopArg = arg: replaceStrings ["\""] ["\"\\\"\""] (toString arg);
    makeFirefoxProfileDesktopItem = attrs:
      let
        mkExec = with lib; { name, profile, ... }: ''
          firefox -p "${ escapeDesktopArg profile }" --class="firefox-${ escapeDesktopArg name }"
        '';
      in
        pkgs.makeDesktopItem ((removeAttrs attrs [ "profile" ]) // {
          exec = mkExec attrs;
          extraEntries = ''
            StartupWMClass="${ escapeDesktopArg attrs.name }"
          '';
        });
    makeFirefoxWebAppDesktopItem = attrs:
      let
        # --class not yet respected: https://bugzilla.mozilla.org/show_bug.cgi?id=1606247
        mkExec = with lib; { app, name, profile ? "private", ... }: ''
          firefox -p "${ escapeDesktopArg profile }" --ssb="${ escapeDesktopArg app }" --class="${ escapeDesktopArg name }"
        '';
      in
        pkgs.makeDesktopItem ((removeAttrs attrs [ "app" "profile" ]) // {
          exec = mkExec attrs;
          extraEntries = ''
            StartupWMClass="${ escapeDesktopArg attrs.name }"
          '';
        });
  in
    (with pkgs; [
      (tor-browser-bundle-bin.override { pulseaudioSupport = true; })
    ])
      ++ [
        (makeFirefoxProfileDesktopItem {
          name = "firefox-work";
          desktopName = "Firefox (Work)";
          icon = "firefox"; # TODO looks different
          profile = "work";
        })
        (makeFirefoxWebAppDesktopItem {
          name = "element";
          desktopName = "Element";
          app = "https://app.element.io";
        })
        (makeFirefoxWebAppDesktopItem {
          name = "youtube-music";
          desktopName = "YouTube Music";
          app = "https://music.youtube.com";
        })
      ];
}
