{ config, pkgs, ... }:

let
  firefox-addons = pkgs.nur.repos.rycee.firefox-addons;
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
      };
      work = {
        id = 1;
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
