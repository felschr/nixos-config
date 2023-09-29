_:

{
  services.udev.extraRules = ''
    # Notify ModemManager this device should be ignored
    ACTION!="add|change|move", GOTO="mm_usb_device_blacklist_end"
    SUBSYSTEM!="usb", GOTO="mm_usb_device_blacklist_end"
    ENV{DEVTYPE}!="usb_device",  GOTO="mm_usb_device_blacklist_end"

    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="a2ca", ENV{ID_MM_DEVICE_IGNORE}="1"

    LABEL="mm_usb_device_blacklist_end"


    # Solo bootloader + firmware access
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="a2ca", TAG+="uaccess"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="a2ca", TAG+="uaccess"

    # ST DFU access
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"

    # U2F Zero
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="8acf", TAG+="uaccess"
  '';
}
