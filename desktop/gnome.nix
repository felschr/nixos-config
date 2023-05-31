{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs;
    with gnomeExtensions; [
      gnome.dconf-editor
      gnome.gnome-tweaks
      native-window-placement
      appindicator
      (pop-shell.overrideAttrs (old: rec {
        version = "unstable-2023-04-27";
        src = fetchFromGitHub {
          owner = "pop-os";
          repo = "shell";
          rev = "b5acccefcaa653791d25f70a22c0e04f1858d96e";
          sha256 = "w6EBHKWJ4L3ZRVmFqZhCqHGumbElQXk9udYSnwjIl6c=";
        };
        patches = [ ];
        postPatch = ''
          for file in */main.js; do
            substituteInPlace $file --replace "gjs" "${pkgs.gjs}/bin/gjs"
          done
        '';
      }))
      gnome-bedtime
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
    gnome.evince
  ];
  programs.gnome-terminal.enable = false;
  programs.geary.enable = false;
}
