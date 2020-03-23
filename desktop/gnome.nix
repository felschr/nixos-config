{ config, pkgs, ... }:

with pkgs;
let
  gnome-shell-extension-pop-shell = stdenv.mkDerivation rec {
    pname = "gnome-shell-extension-pop-shell";
    version = "2020-03-18";

    src = fetchFromGitHub {
      owner = "pop-os";
      repo = "shell";
      rev = "0c480fb8c0f0c39a5842cff89f38d807600c2a14";
      sha256 = "053csqmbj37f7kilsav9z1q7b0v0rrqvbqzk28qkpddkpvysvh7m";
    };

    nativeBuildInputs = [ glib ];
    buildInputs = [ nodePackages.typescript ];

    # the gschema doesn't seem to be installed properly (see dconf)
    makeFlags = [ "INSTALLBASE=$(out)/share/gnome-shell/extensions" ];
  };
in
{
  environment.systemPackages = with pkgs; [
    gnome3.dconf-editor
    gnome3.gnome-tweaks
    gnome3.gnome-shell-extensions # required for user-theme
    gnomeExtensions.dash-to-panel
    gnomeExtensions.appindicator
    gnome-shell-extension-pop-shell
  ];

  # Enable Gnome 3
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome3.enable = true;
  environment.gnome3.excludePackages = with pkgs; [
    gnome3.geary
    gnome3.gnome-weather
    gnome3.gnome-calendar
    gnome3.gnome-maps
    gnome3.gnome-contacts
    gnome3.gnome-software
    gnome3.gnome-packagekit
    gnome3.totem
    gnome3.epiphany
  ];

  programs.gnome-terminal.enable = false;
}
