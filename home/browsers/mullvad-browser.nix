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

  commonSearch = {
    force = true;
    # TODO defaults don't work
    default = "Qwant";
    privateDefault = "Qwant";
    order = [
      "Qwant"
      "Ecosia"
      "DuckDuckGo"
      "Startpage"
      "kagi"
    ];
    engines = {
      # builtin
      "Startpage".metaData.alias = "@s";
      "DuckDuckGo".metaData.alias = "@d";

      # extra
      "Qwant" = {
        urls = [ { template = "https://www.qwant.com/?q={searchTerms}"; } ];
        iconURL = "https://www.qwant.com/favicon.ico";
        definedAliases = [ "@q" ];
      };
      "Ecosia" = {
        urls = [ { template = "https://www.ecosia.org/search?q={searchTerms}"; } ];
        iconURL = "https://www.ecosia.org/favicon.ico";
        definedAliases = [ "@e" ];
      };
      "kagi" = {
        urls = [ { template = "https://kagi.com/search?q={searchTerms}"; } ];
        iconURL = "https://kagi.com/favicon.ico";
        definedAliases = [ "@k" ];
      };
      "GitHub" = {
        urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
        iconURL = "https://github.com/favicon.ico";
        definedAliases = [ "@gh" ];
      };
      "GitLab" = {
        urls = [ { template = "https://gitlab.com/search?search={searchTerms}"; } ];
        iconURL = "https://gitlab.com/favicon.ico";
        definedAliases = [ "@gl" ];
      };
      "Codeberg" = {
        urls = [ { template = "https://codeberg.org/explore/repos?q={searchTerms}"; } ];
        iconURL = "https://codeberg.org/favicon.ico";
        definedAliases = [ "@cb" ];
      };
      "Nix Packages" = {
        urls = [ { template = "https://search.nixos.org/packages?query={searchTerms}"; } ];
        icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "@np" ];
      };
      "NixOS Options" = {
        urls = [ { template = "https://search.nixos.org/options?query={searchTerms}"; } ];
        icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "@no" ];
      };
      "Nix Flakes: Packages" = {
        urls = [ { template = "https://search.nixos.org/flakes?type=packages&query={searchTerms}"; } ];
        icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "@nfp" ];
      };
      "Nix Flakes: Options" = {
        urls = [ { template = "https://search.nixos.org/flakes?type=options&query={searchTerms}"; } ];
        icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "@nfo" ];
      };
      "NixOS Wiki" = {
        urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
        icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "@nw" ];
      };
      "Crates.io" = {
        urls = [ { template = "https://crates.io/search?q={searchTerms}"; } ];
        iconURL = "https://crates.io/favicon.ico";
        definedAliases = [ "@rc" ];
      };
      "Docs.rs" = {
        urls = [ { template = "https://docs.rs/releases/search?query={searchTerms}"; } ];
        iconURL = "https://docs.rs/favicon.ico";
        definedAliases = [ "@rd" ];
      };
      "Rust Book" = {
        urls = [ { template = "https://doc.rust-lang.org/book/?search={searchTerms}"; } ];
        iconURL = "https://doc.rust-lang.org/book/favicon.svg";
        definedAliases = [ "@rb" ];
      };
      "Rust std" = {
        urls = [ { template = "https://doc.rust-lang.org/stable/std/?search={searchTerms}"; } ];
        iconURL = "https://www.rust-lang.org/static/images/favicon.svg";
        definedAliases = [ "@rs" ];
      };
      "npm" = {
        urls = [ { template = "https://www.npmjs.com/search?q={searchTerms}"; } ];
        iconURL = "https://static-production.npmjs.com/da3ab40fb0861d15c83854c29f5f2962.png";
        definedAliases = [ "@npm" ];
      };
      "PyPI" = {
        urls = [ { template = "https://pypi.org/search/?q={searchTerms}"; } ];
        iconURL = "https://pypi.org/favicon.ico";
        definedAliases = [ "@pypi" ];
      };
      "Stack Overflow" = {
        urls = [ { template = "https://stackoverflow.com/search?q={searchTerms}"; } ];
        iconURL = "https://cdn.sstatic.net/Sites/stackoverflow/Img/favicon.ico";
        definedAliases = [ "@so" ];
      };
      "Wikipedia" = {
        urls = [ { template = "https://en.wikipedia.org/wiki/{searchTerms}"; } ];
        iconURL = "https://en.wikipedia.org/favicon.ico";
        definedAliases = [ "@w" ];
      };
      "Wolfram Alpha" = {
        urls = [ { template = "https://www.wolframalpha.com/input?i={searchTerms}"; } ];
        iconURL = "https://www.wolframalpha.com/_next/static/images/favicon_1zbE9hjk.ico";
        definedAliases = [ "@wa" ];
      };
      "Reddit" = {
        urls = [ { template = "https://www.reddit.com/search/?q={searchTerms}"; } ];
        iconURL = "https://www.reddit.com/favicon.ico";
        definedAliases = [ "@r" ];
      };
    };
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
        search = commonSearch;
        extensions = commonExtensions;
      };
      work = {
        id = 1;
        settings = commonSettings;
        search = commonSearch;
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
