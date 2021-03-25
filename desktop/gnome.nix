{ config, pkgs, ... }:

with pkgs;
let
  pop-shell = stdenv.mkDerivation rec {
    pname = "pop-shell";
    version = "2021-03-16";

    src = fetchFromGitHub {
      owner = "pop-os";
      repo = "shell";
      rev = "77650a9aafa2f7adc328424e36dc91705411feb4";
      sha256 = "0dff8gl83kx2qzzybk9hxbszv9p8qw8j40qirvfbx6mly7sqknng";
    };

    nativeBuildInputs = [ glib nodePackages.typescript ];

    # the gschema doesn't seem to be installed properly (see dconf)
    makeFlags = [
      "INSTALLBASE=$(out)/share/gnome-shell/extensions"
      "PLUGIN_BASE=$(out)/share/pop-shell/launcher"
      "SCRIPTS_BASE=$(out)/share/pop-shell/scripts"
    ];
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
  services.xserver.desktopManager.gnome3.extraGSettingsOverrides = ''
    [org/gnome/desktop/input-sources]
    sources=[('xkb', 'gb'), ('xkb', 'mozc-jp')]
  '';

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
