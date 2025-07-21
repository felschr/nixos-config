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
    default = "qwant";
    privateDefault = "qwant";
    order = [
      "qwant"
      "ecosia"
      "ddg"
      "startpage"
      "kagi"
    ];
    engines = {
      # builtin
      startpage.metaData.alias = "@s";
      ddg.metaData.alias = "@d";

      # extra
      qwant = {
        name = "Qwant";
        urls = [ { template = "https://www.qwant.com/?q={searchTerms}"; } ];
        iconMapObj."16" = "https://www.qwant.com/favicon.ico";
        definedAliases = [ "@q" ];
      };
      ecosia = {
        name = "Ecosia";
        urls = [ { template = "https://www.ecosia.org/search?q={searchTerms}"; } ];
        iconMapObj."16" = "https://www.ecosia.org/favicon.ico";
        definedAliases = [ "@e" ];
      };
      kagi = {
        name = "Kagi";
        urls = [ { template = "https://kagi.com/search?q={searchTerms}"; } ];
        iconMapObj."16" = "https://kagi.com/favicon.ico";
        definedAliases = [ "@k" ];
      };
      github = {
        name = "GitHub";
        urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
        iconMapObj."16" = "https://github.com/favicon.ico";
        definedAliases = [ "@gh" ];
      };
      gitlab = {
        name = "GitLab";
        urls = [ { template = "https://gitlab.com/search?search={searchTerms}"; } ];
        iconMapObj."16" = "https://gitlab.com/favicon.ico";
        definedAliases = [ "@gl" ];
      };
      codeberg = {
        name = "Codeberg";
        urls = [ { template = "https://codeberg.org/explore/repos?q={searchTerms}"; } ];
        iconMapObj."16" = "https://codeberg.org/favicon.ico";
        definedAliases = [ "@cb" ];
      };
      nix-packages = {
        name = "Nix Packages";
        urls = [ { template = "https://search.nixos.org/packages?query={searchTerms}"; } ];
        icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "@np" ];
      };
      nixos-options = {
        name = "NixOS Options";
        urls = [ { template = "https://search.nixos.org/options?query={searchTerms}"; } ];
        icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "@no" ];
      };
      nix-flakes-packages = {
        name = "Nix Flakes: Packages";
        urls = [ { template = "https://search.nixos.org/flakes?type=packages&query={searchTerms}"; } ];
        icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "@nfp" ];
      };
      nix-flakes-options = {
        name = "Nix Flakes: Options";
        urls = [ { template = "https://search.nixos.org/flakes?type=options&query={searchTerms}"; } ];
        icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "@nfo" ];
      };
      nixos-wiki = {
        name = "NixOS Wiki";
        urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
        icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "@nw" ];
      };
      crates-io = {
        name = "Crates.io";
        urls = [ { template = "https://crates.io/search?q={searchTerms}"; } ];
        iconMapObj."16" = "https://crates.io/favicon.ico";
        definedAliases = [ "@rc" ];
      };
      docs-rs = {
        name = "Docs.rs";
        urls = [ { template = "https://docs.rs/releases/search?query={searchTerms}"; } ];
        iconMapObj."16" = "https://docs.rs/favicon.ico";
        definedAliases = [ "@rd" ];
      };
      rust-book = {
        name = "Rust Book";
        urls = [ { template = "https://doc.rust-lang.org/book/?search={searchTerms}"; } ];
        iconMapObj."16" = "https://doc.rust-lang.org/book/favicon.svg";
        definedAliases = [ "@rb" ];
      };
      rust-std = {
        name = "Rust std";
        urls = [ { template = "https://doc.rust-lang.org/stable/std/?search={searchTerms}"; } ];
        iconMapObj."16" = "https://www.rust-lang.org/static/images/favicon.svg";
        definedAliases = [ "@rs" ];
      };
      npm = {
        name = "npm";
        urls = [ { template = "https://www.npmjs.com/search?q={searchTerms}"; } ];
        iconMapObj."16" = "https://static-production.npmjs.com/da3ab40fb0861d15c83854c29f5f2962.png";
        definedAliases = [ "@npm" ];
      };
      pypi = {
        name = "PyPI";
        urls = [ { template = "https://pypi.org/search/?q={searchTerms}"; } ];
        iconMapObj."16" = "https://pypi.org/favicon.ico";
        definedAliases = [ "@pypi" ];
      };
      stack-overflow = {
        name = "Stack Overflow";
        urls = [ { template = "https://stackoverflow.com/search?q={searchTerms}"; } ];
        iconMapObj."16" = "https://cdn.sstatic.net/Sites/stackoverflow/Img/favicon.ico";
        definedAliases = [ "@so" ];
      };
      wikipedia = {
        name = "Wikipedia";
        urls = [ { template = "https://en.wikipedia.org/wiki/{searchTerms}"; } ];
        iconMapObj."16" = "https://en.wikipedia.org/favicon.ico";
        definedAliases = [ "@w" ];
      };
      wolfram-alpha = {
        name = "Wolfram Alpha";
        urls = [ { template = "https://www.wolframalpha.com/input?i={searchTerms}"; } ];
        iconMapObj."16" = "https://www.wolframalpha.com/_next/static/images/favicon_1zbE9hjk.ico";
        definedAliases = [ "@wa" ];
      };
      reddit = {
        name = "Reddit";
        urls = [ { template = "https://www.reddit.com/search/?q={searchTerms}"; } ];
        iconMapObj."16" = "https://www.reddit.com/favicon.ico";
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
        extensions.packages = commonExtensions;
      };
      work = {
        id = 1;
        settings = commonSettings;
        search = commonSearch;
        extensions.packages =
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
