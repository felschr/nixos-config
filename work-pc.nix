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
      ./home/felschr-work.nix 
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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "pilot1-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "uk";
    defaultLocale = "en_GB.UTF-8";
    inputMethod.enabled = "ibus";
    inputMethod.ibus.engines = with pkgs.ibus-engines; [ uniemoji ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  programs.slock.enable = true;

  environment.shellAliases = {
    chromium = "chromium --force-dark-mode";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    curl
    networkmanager
    neovim
    docker-compose

    # gnome3.gnome-screensaver
    gnome3.dconf-editor
    gnome3.gnome-tweaks
    gnomeExtensions.dash-to-panel
    gnomeExtensions.topicons-plus
  ];

  # Use noto fonts with emoji support
  fonts.enableDefaultFonts = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.bluetooth.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };
  hardware.bluetooth.extraConfig = "
    [General]
    Enable=Source,Sink,Media,Socket
  ";

  # NVIDIA drivers
  # services.xserver.videoDrivers = [ "intel" "vesa" ];
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia.optimus_prime.enable = true;
  # hardware.nvidia.optimus_prime.nvidiaBusId = "PCI:2:0:0";
  # hardware.nvidia.optimus_prime.intelBusId = "PCI:0:2:0";
  hardware.bumblebee.enable = true;
  # hardware.bumblebee.connectDisplay = true;
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
  # services.xserver.displayManager.lightdm.enable = true;

  # services.xserver.windowManager.default = "xmonad";
  # services.xserver.windowManager.xmonad.enable = true;
  # services.xserver.windowManager.i3.enable = true;

  services.xserver.desktopManager.gnome3.enable = true;
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

  services.dbus.packages = with pkgs; [
    gnome3.dconf gnome2.GConf
  ];

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.felschr = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "docker" "disk" "vboxusers" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  nix.autoOptimiseStore = true;
  # nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

  system.autoUpgrade.enable = true;
}
