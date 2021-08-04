{ config, pkgs, ... }:

with pkgs;
let
  pop-shell = stdenv.mkDerivation rec {
    pname = "pop-shell";
    version = "2021-05-07";

    src = fetchFromGitHub {
      owner = "pop-os";
      repo = "shell";
      rev = "9507dc38f75f56e657cf071d5f8dc578c5dc9352";
      sha256 = "161946y5nk1nlxafhkxyshqn4va10rk911bdbcwxjnak1w7557gm";
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
      gnome.dconf-editor
      gnome.gnome-tweaks
      gnome.gnome-shell-extensions # required for user-theme
      appindicator
      pop-shell
    ];

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.gdm.nvidiaWayland = true;
  services.xserver.displayManager.defaultSession = "gnome-xorg";
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org/gnome/desktop/input-sources]
    sources=[('xkb', 'gb'), ('xkb', 'mozc-jp')]

    [org/gnome/mutter]
    experimental-features=['kms-modifiers']
  '';
  programs.xwayland.enable = true;

  # exclude some default applications
  environment.gnome.excludePackages = with pkgs; [
    gnome.gnome-weather
    gnome.gnome-calendar
    gnome.gnome-maps
    gnome.gnome-contacts
    gnome.gnome-software
    gnome.totem
    gnome.epiphany
  ];
  programs.gnome-terminal.enable = false;
  programs.geary.enable = false;
}
