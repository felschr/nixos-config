{ config, pkgs, ... }:

with pkgs;
let
  gnome-shell-extension-pop-shell = stdenv.mkDerivation rec {
    pname = "gnome-shell-extension-pop-shell";
    version = "2020-08-14";

    src = fetchFromGitHub {
      owner = "pop-os";
      repo = "shell";
      rev = "69415ea1fa221a15e8b1c1f9f9ab0b4ba302ee9c";
      sha256 = "0p0kh1f7achrr51mwmxnnliz82qmfdi37wvc9xhf02w0cx28hlml";
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

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome3.enable = true;

  # exclude some default applications
  environment.gnome3.excludePackages = with pkgs; [
    gnome3.gnome-weather
    gnome3.gnome-calendar
    gnome3.gnome-maps
    gnome3.gnome-contacts
    gnome3.gnome-software
    gnome3.totem
    gnome3.epiphany
  ];
  programs.gnome-terminal.enable = false;
  programs.geary.enable = false;
}
