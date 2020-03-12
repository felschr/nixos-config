{ config, pkgs, ... }:

with pkgs;
let
  gnome-shell-extension-pop-shell = stdenv.mkDerivation rec {
    pname = "gnome-shell-extension-pop-shell";
    version = "2020-03-12";

    src = fetchFromGitHub {
      owner = "pop-os";
      repo = "shell";
      rev = "6cd22230503b7bba0cc35f499a040f7d7eb44637";
      sha256 = "1574c9v3ifkjag8kbib28rjzal7h3mb78inssl92wf0hvrlsvilr";
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
    gnome3.epiphany
  ];
} 
