{ pkgs, lib, ... }:

{
  services.desktopManager.cosmic.enable = true;

  specialisation = {
    cosmic.configuration = {
      services.displayManager.gdm.enable = lib.mkForce false;
      services.desktopManager.gnome.enable = lib.mkForce false;

      services.desktopManager.cosmic.enable = true;
      services.displayManager.cosmic-greeter.enable = true;
    };
  };
}
