# Import unstable and home-manager channels:
# sudo nix-channel --add http://nixos.org/channels/nixos-unstable nixos-unstable
# sudo nix-channel --add https://github.com/rycee/home-manager/archive/release-19.03.tar.gz home-manager
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
    (self: super: {
      libu2f-host = unstable.libu2f-host;
    })
  ];

  # Use the systemd-boot EFI boot loader.
  boot.initrd.luks.devices = [
    { 
      name = "root";
      device = "/dev/disk/by-uuid/a08f2cb3-2a6d-4dbc-b846-4a42ca137117";
      preLVM = true;
      allowDiscards = true;
    }
  ];
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

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
    gnomeExtensions.dash-to-panel
    gnomeExtensions.topicons-plus
    unstable.libu2f-host
  ];

  # Use noto fonts with emoji support
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];
  fonts.fontconfig.penultimate.enable = false;
  fonts.fontconfig.defaultFonts.monospace = ["Noto Color Emoji"];
  fonts.fontconfig.defaultFonts.sansSerif = ["Noto Color Emoji"];
  fonts.fontconfig.defaultFonts.serif = ["Noto Color Emoji"];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  # NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.driSupport32Bit = true;

  # Enable special device support
  hardware.ledger.enable = true;
  hardware.u2f.enable = true;

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
    gnome3.gnome-weather
    gnome3.gnome-calendar
    gnome3.gnome-todo
    # gnome3.gnome-books
    gnome3.gnome-maps
    gnome3.gnome-contacts
    gnome3.gnome-software
    gnome3.gnome-packagekit
    gnome3.epiphany
    gnome3.evolution
    gnome3.accerciser
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
  system.stateVersion = "19.03"; # Did you read the comment?

}
