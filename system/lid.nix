{ config, lib, ... }:

{
  services.acpid = lib.mkIf config.services.fprintd.enable {
    enable = true;
    handlers.lidClosed = {
      event = "button/lid \\w+ close";
      action = ''
        echo "Lid closed. Disabling fprintd."
        systemctl stop fprintd
        ln -s /dev/null /run/systemd/transient/fprintd.service
        systemctl daemon-reload
      '';
    };
    handlers.lidOpen = {
      event = "button/lid \\w+ open";
      action = ''
        if ! $(systemctl is-active --quiet fprintd); then
          echo "Lid open. Enabling fprintd."
          rm -f /run/systemd/transient/fprintd.service
          systemctl daemon-reload
          systemctl start fprintd
        fi
      '';
    };
  };
}
