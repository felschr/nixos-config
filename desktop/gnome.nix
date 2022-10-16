{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs;
    with gnomeExtensions; [
      gnome.dconf-editor
      gnome.gnome-tweaks
      native-window-placement
      appindicator
      (pop-shell.overrideAttrs (old: rec {
        version = "unstable-2022-10-11";
        src = fetchFromGitHub {
          owner = "pop-os";
          repo = "shell";
          rev = "886a069c0582b371e90ac3602b1747ea5fba616c";
          sha256 = "DwJ3IFhYuEW0LQrmN/mOspEiudj4X5BCLhdOyP74EVs=";
        };
        patches = [ ];
        postPatch = ''
          for file in */main.js; do
            substituteInPlace $file --replace "gjs" "${pkgs.gjs}/bin/gjs"
          done
        '';
      }))
    ];

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.input-sources]
    sources=[('xkb', 'gb'), ('xkb', 'mozc-jp')]

    [org.gnome.settings-daemon.plugins.color]
    night-light-enabled=true
    night-light-last-coordinates=(53.2593, 10.4)
    night-light-temperature=uint32 3700
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
