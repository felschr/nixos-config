{ config, nixosConfig, pkgs, lib, ... }:

with lib;
let
  inherit (pkgs.nur.repos.rycee) firefox-addons;

  prefer-dark-theme =
    config.gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme;

  sharedSettings = {
    # Privacy & Security Improvements
    "browser.contentblocking.category" = "strict";
    "browser.urlbar.speculativeConnect.enabled" = false;
    "dom.security.https_only_mode" = true;
    "media.eme.enabled" = false; # disables DRM
    # causes CORS error on waves.exchange when set to 2
    "network.http.referer.XOriginPolicy" = 1;
    "network.http.referer.XOriginTrimmingPolicy" = 2;
    "network.IDN_show_punycode" = true;
    # forces ui.systemUsesDarkTheme to false
    # "privacy.resistFingerprinting" = true;
    # "webgl.disabled" = true;

    # Disable Telemetry
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.ping-centre.telemetry" = false;
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "toolkit.telemetry.hybridContent.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.healthreport.service.enabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;

    # Disable Personalisation & Sponsored Content
    "browser.discovery.enabled" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" =
      false;
    "browser.newtabpage.activity-stream.feeds.snippets" = false;

    # Disable Experiments & Studies
    "experiments.activeExperiment" = false;
    "experiments.enabled" = false;
    "experiments.supported" = false;
    "network.allow-experiments" = false;
    "app.normandy.enabled" = false;
    "app.shield.optoutstudies.enabled" = false;

    # Search
    "browser.search.defaultenginename" = "DuckDuckGo";
    "browser.search.selectedEngine" = "DuckDuckGo";

    # Disable DNS over HTTPS (done system-wide)
    "network.trr.mode" = 5;

    # Theme
    "browser.theme.toolbar-theme" = 0;
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
    "browser.uitour.enabled" = false;
    "browser.startup.page" = 3;
    "browser.toolbars.bookmarks.visibility" = "newtab";
    "browser.tabs.drawInTitlebar" = true;
    "browser.aboutConfig.showWarning" = false;
    "signon.rememberSignons" = false;
    "services.sync.engine.passwords" = false;
    "extensions.update.enabled" = false;
    "extensions.update.autoUpdateDefault" = false;
    "extensions.pocket.enabled" = false;
    "general.autoScroll" = true;
  } // optionalAttrs nixosConfig.services.mullvad-vpn.enable {
    # Mullvad SOCKS proxy
    "network.proxy.type" = 1;
    "network.proxy.socks" = "10.64.0.1";
    "network.proxy.socks_port" = 1080;
    "network.proxy.no_proxies_on" = "192.168.1.1/24";
  };
in {
  programs.firefox = {
    enable = true;
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
      terms-of-service-didnt-read
      vimium
      ipfs-companion
      bitwarden
      darkreader
      languagetool
      metamask
      libredirect
      to-deepl
      # not available yet:
      # google-lighthouse
    ];
  };

  home.packages = let
    makeFirefoxProfileBin = args@{ profile, ... }:
      let
        name = "firefox-${profile}";
        scriptBin = pkgs.writeScriptBin name ''
          firefox -P "${profile}" --name="${name}" $@
        '';
        desktopFile = pkgs.makeDesktopItem ((removeAttrs args [ "profile" ])
          // {
            inherit name;
            exec = "${scriptBin}/bin/${name} %U";
            extraConfig.StartupWMClass = name;
            genericName = "Web Browser";
            mimeTypes = [
              "text/html"
              "text/xml"
              "application/xhtml+xml"
              "application/vnd.mozilla.xul+xml"
              "x-scheme-handler/http"
              "x-scheme-handler/https"
            ];
            categories = [ "Network" "WebBrowser" ];
          });
      in pkgs.runCommand name { } ''
        mkdir -p $out/{bin,share}
        cp -r ${scriptBin}/bin/${name} $out/bin/${name}
        cp -r ${desktopFile}/share/applications $out/share/applications
      '';
  in with pkgs; [
    (tor-browser-bundle-bin.override { pulseaudioSupport = true; })
    (makeFirefoxProfileBin {
      profile = "work";
      desktopName = "Firefox (Work)";
      icon = "firefox";
    })
  ];
}
