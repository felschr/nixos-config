{ inputs, config, pkgs, lib, ... }:

with lib;
let
  firefox-addons = inputs.firefox-addons.packages.${pkgs.system}
    // (import ./firefoxAddons.nix { inherit inputs pkgs lib; });

  inherit (import ../modules/firefox/common.nix { inherit config lib pkgs; })
    mkConfig;

  arkenfoxConfig = builtins.readFile "${inputs.arkenfox-userjs}/user.js";

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
    "keyword.enabled" = true;

    # Enable IPv6 again
    "network.dns.disableIPv6" = false;

    # Disable extension auto updates
    "extensions.update.enabled" = false;
    "extensions.update.autoUpdateDefault" = false;
  };

  # use extraConfig to load arkenfox user.js before settings
  sharedExtraConfig = ''
    ${arkenfoxConfig}

    ${mkConfig sharedSettings}
  '';

  commonExtensions = with firefox-addons; [
    german-dictionary
    ublock-origin
    proton-pass
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
        extensions = commonExtensions;
      };
      work = {
        id = 1;
        extraConfig = sharedExtraConfig;
        extensions = commonExtensions
          ++ (with firefox-addons; [ bitwarden react-devtools reduxdevtools ]);
      };
    };
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
