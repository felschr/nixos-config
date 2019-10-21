{ config, pkgs, ... }:

{
  services.udev.extraRules = ''
    # STM32 rules for the Planck EZ Standard / Glow
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", \
        MODE:="0666", \
        SYMLINK+="stm32_dfu"
  '';
}
