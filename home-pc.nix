# Import unstable and home-manager channels:
# sudo nix-channel --add http://nixos.org/channels/nixos-unstable nixos-unstable
# sudo nix-channel --add https://github.com/rycee/home-manager/archive/release-19.09.tar.gz home-manager
# sudo nix-channel --update

{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> {
    config = removeAttrs config.nixpkgs.config [ "packageOverrides" ];
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # configure unfree and unstable packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
  ];

  # Use the systemd-boot EFI boot loader.
  boot.initrd.luks.devices = [
    { 
      name = "root";
      device = "/dev/disk/by-partlabel/nixos";
      preLVM = true;
      allowDiscards = true;
    }
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_5_2;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "felix-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "uk";
    defaultLocale = "en_GB.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    curl
    networkmanager
    neovim
    gnome3.gnome-tweaks
    gnomeExtensions.dash-to-panel
    gnomeExtensions.topicons-plus
  ];

  # Use noto fonts with emoji support
  fonts.enableDefaultFonts = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.extraConfig = "
    [General]
    Enable=Source,Sink,Media,Socket
  ";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    support32Bit = true;
    package = pkgs.pulseaudioFull;
  };

  # NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.driSupport32Bit = true;

  # Enable special device support
  hardware.ledger.enable = true;
  hardware.u2f.enable = true;
  services.udev.extraRules = ''
    # Nano S
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0001|1000|1001|1002|1003|1004|1005|1006|1007|1008|1009|100a|100b|100c|100d|100e|100f|1010|1011|1012|1013|1014|1015|1016|1017|1018|1019|101a|101b|101c|101d|101e|101f", TAG+="uaccess", TAG+="udev-acl"
  '';

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "gb";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable Gnome 3
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome3.enable = true;
  services.dbus.packages = with pkgs; [
    gnome3.dconf gnome2.GConf
  ];
  environment.gnome3.excludePackages = with pkgs; [
    gnome3.geary
    gnome3.gnome-weather
    gnome3.gnome-calendar
    gnome3.gnome-maps
    gnome3.gnome-contacts
    gnome3.gnome-software
    gnome3.gnome-packagekit
    gnome3.epiphany
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.felschr = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };
  home-manager.users.felschr = import ./home/felschr.nix;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

  system.autoUpgrade.enable = true;

  nix.gc.automatic = true;
  nix.autoOptimiseStore = true;
}
