{ config, pkgs, ... }:

with pkgs;
let
  pop-shell = stdenv.mkDerivation rec {
    pname = "pop-shell";
    version = "2020-09-08";

    src = fetchFromGitHub {
      owner = "pop-os";
      repo = "shell";
      rev = "017c92e04f4eefead2561fa35559891eb83388c9";
      sha256 = "12ch08ny3m2hf6ii2niw0x07pfcknl3r8rixvijaj36wvbgviaxa";
    };

    nativeBuildInputs = [ glib ];
    buildInputs = [ nodePackages.typescript ];

    # the gschema doesn't seem to be installed properly (see dconf)
    makeFlags = [ "INSTALLBASE=$(out)/share/gnome-shell/extensions" ];
  };
in {
  environment.systemPackages = with pkgs;
    with gnomeExtensions; [
      gnome3.dconf-editor
      gnome3.gnome-tweaks
      gnome3.gnome-shell-extensions # required for user-theme
      dash-to-panel
      appindicator
      pop-shell
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
