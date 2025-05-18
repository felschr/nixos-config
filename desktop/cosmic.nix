{ pkgs, lib, ... }:

{
  services.desktopManager.cosmic.enable = true;

  specialisation = {
    cosmic.configuration = {
      services.xserver.displayManager.gdm.enable = lib.mkForce false;
      services.xserver.desktopManager.gnome.enable = lib.mkForce false;

      services.desktopManager.cosmic.enable = true;
      services.displayManager.cosmic-greeter.enable = true;
    };
  };
}
