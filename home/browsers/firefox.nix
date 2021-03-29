{ config, pkgs, lib, ... }:

with lib;
let
  firefox-addons = pkgs.nur.repos.rycee.firefox-addons;

  prefer-dark-theme =
    config.gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme;

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
    "dom.security.https_only_mode" = true;
    "dom.security.https_only_mode_ever_enabled" = true;
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
    "extensions.activeThemeID" = concatStrings [
      "firefox-compact-"
      (if prefer-dark-theme then "dark" else "light")
      "@mozilla.org"
    ];
    "devtools.theme" = if prefer-dark-theme then "dark" else "light";

    # i18n
    "intl.accept_languages" = "en-GB, en";
    "intl.regional_prefs.use_os_locales" = true;

    # dev tools
    "devtools.inspector.color-scheme-simulation.enabled" = true;
    "devtools.inspector.showAllAnonymousContent" = true;

    # Other
    "browser.startup.page" = 3;
    "browser.toolbars.bookmarks.visibility" = "newtab";
    "browser.tabs.drawInTitlebar" = true;
    "browser.aboutConfig.showWarning" = false;
    "signon.rememberSignons" = false;
    "services.sync.engine.passwords" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" =
      false;
    "browser.newtabpage.activity-stream.feeds.snippets" = false;
    "extensions.update.enabled" = false;
    "extensions.update.autoUpdateDefault" = false;
  };
in {
  programs.firefox = {
    enable = true;
    package = with pkgs;
      wrapFirefox firefox-unwrapped { cfg.enableFXCastBridge = true; };
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
      ublock-origin
      decentraleyes
      clearurls
      terms-of-service-didnt-read
      vimium
      ipfs-companion
      bitwarden
      darkreader
      languagetool
      metamask
      privacy-redirect
      # not available yet:
      # fx_cast
      # google-lighthouse
    ];
  };

  home.packages = let
    escapeDesktopArg = arg:
      replaceStrings [ ''"'' ] [ ''"\""'' ] (toString arg);
    makeFirefoxProfileBin = args@{ profile, ... }:
      let
        name = "firefox-${profile}";
        scriptBin = pkgs.writeScriptBin name ''
          firefox -p "${escapeDesktopArg profile}" --class="${
            escapeDesktopArg name
          }" $@
        '';
        desktopFile = pkgs.makeDesktopItem ((removeAttrs args [ "profile" ])
          // {
            inherit name;
            exec = "${scriptBin}/bin/${name} %U";
            extraEntries = ''
              StartupWMClass="${escapeDesktopArg name}"
            '';
            genericName = "Web Browser";
            mimeType = lib.concatStringsSep ";" [
              "text/html"
              "text/xml"
              "application/xhtml+xml"
              "application/vnd.mozilla.xul+xml"
              "x-scheme-handler/http"
              "x-scheme-handler/https"
              "x-scheme-handler/ftp"
            ];
            categories = "Network;WebBrowser;";
          });
      in pkgs.runCommand name { } ''
        mkdir -p $out/{bin,share}
        cp -r ${scriptBin}/bin/${name} $out/bin/${name}
        cp -r ${desktopFile}/share/applications $out/share/applications
      '';
  in (with pkgs;
    [ (tor-browser-bundle-bin.override { pulseaudioSupport = true; }) ]) ++ [
      (makeFirefoxProfileBin {
        profile = "work";
        desktopName = "Firefox (Work)";
        icon = "firefox";
      })
    ];
}
