{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ podman-compose ];

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.podman.extraPackages = with pkgs; [ ];
  virtualisation.podman.defaultNetwork.dnsname.enable = true;
}
