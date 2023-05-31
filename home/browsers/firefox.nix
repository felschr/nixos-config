{ config, nixosConfig, pkgs, lib, ... }:

with lib;
let
  firefox-addons = pkgs.nur.repos.rycee.firefox-addons
    // (import ./firefoxAddons.nix { inherit pkgs lib; });

  inherit (import ../modules/firefox/common.nix { inherit config lib pkgs; })
    mkConfig;

  arkenfoxConfig = builtins.readFile pkgs.nur.repos.slaier.arkenfox-userjs;

  # Relax some arkenfox settings, to get a less strict
  # alternative to Mullvad Browser to fallback on.
  sharedSettings = {
    # Enable restoring sessions
    "browser.startup.page" = 3;

    # Don't delete data on shutdown (cookies, sessions, windows, ...)
    "privacy.sanitize.sanitizeOnShutdown" = false;

    # Don't do default browser check
    "browser.shell.checkDefaultBrowser" = false;

    # Disable Pocket
    "extensions.pocket.enabled" = false;

    # Enable search in location bar
    "keyword.enabled" = false;

    # Enable IPv6 again
    "network.dns.disableIPv6" = false;
  };

  # use extraConfig to load arkenfox user.js before settings
  sharedExtraConfig = ''
    ${arkenfoxConfig}

    ${mkConfig sharedSettings}
  '';

  commonExtensions = with firefox-addons; [
    german-dictionary
    ublock-origin
    bitwarden
    libredirect
    zotero-connector
  ];
in {
  programs.firefox = {
    enable = true;
    profiles = {
      private = {
        id = 0;
        extraConfig = sharedExtraConfig;
        # extensions = commonExtensions ++ (with firefox-addons; [ metamask ]);
      };
      work = {
        id = 1;
        extraConfig = sharedExtraConfig;
        # extensions = commonExtensions
        #   ++ (with firefox-addons; [ react-devtools reduxdevtools ]);
      };
    };
    extensions = commonExtensions ++ (with firefox-addons; [ metamask ]);
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
  in [
    (makeFirefoxProfileBin {
      profile = "work";
      desktopName = "Firefox (Work)";
      icon = "firefox";
    })
  ];
}
