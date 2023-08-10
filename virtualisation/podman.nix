{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ podman-compose ];

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  virtualisation.podman.autoPrune.enable = true;
  virtualisation.podman.autoPrune.dates = "weekly";
  virtualisation.podman.autoPrune.flags = [ "--all" ];

  systemd.services.podman-auto-update = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.podman}/bin/podman auto-update";
      ExecStartPost = "${pkgs.podman}/bin/podman image prune -f";
    };
  };

  systemd.timers.podman-auto-update = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "03:30";
      Persistent = true;
    };
  };
}
