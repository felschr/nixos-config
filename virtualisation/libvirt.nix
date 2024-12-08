{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    virt-manager
    gnome-boxes
  ];

  environment.sessionVariables.LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];

  # Users need to be in groups: libvirtd, qemu-libvirtd
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.runAsRoot = false;
  virtualisation.libvirtd.qemu.ovmf.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true;
  virtualisation.libvirtd.onBoot = "ignore";
  virtualisation.libvirtd.onShutdown = "shutdown";
  virtualisation.spiceUSBRedirection.enable = true;

  programs.dconf.enable = true;
}
