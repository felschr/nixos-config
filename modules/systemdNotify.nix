{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

# TODO replace with more secure service, e.g. matrix-sendmail (matrix-commander)
# needs to support queueing
# flake: https://github.com/emmanuelrosa/erosanix/blob/master/modules/matrix-sendmail.nix
# call `matrix-commander --login` with credentials on service start
let
  cfg = config.systemd.notify;
  sendmail = pkgs.writeScript "sendmail" ''
    #!${pkgs.runtimeShell}

    ${pkgs.system-sendmail}/bin/sendmail -t <<ERRMAIL
    To: ${cfg.email.mailTo}
    From: ${cfg.email.mailFrom}
    Subject: Service $1 failed
    Content-Transfer-Encoding: 8bit
    Content-Type: text/plain; charset=UTF-8

    $(systemctl status --full "$1")
    ERRMAIL
  '';

  checkConditions = pkgs.writeScript "check-conditions" ''
    #!/bin/sh
    STATUS=$(systemctl status --full "$1")

    case "$STATUS" in
      *"activating (auto-restart) (Result: timeout)"*) exit 1 ;;
      *) exit 0 ;;
    esac
  '';
in
{
  options = {
    systemd.notify = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable notifications for failed services.";
      };

      method = mkOption {
        type = types.enum [
          "libnotify"
          "email"
        ];
        default = "libnotify";
        description = "The method for sending notifications.";
      };

      libnotify.user = mkOption {
        type = types.str;
        default = null;
        description = "User session to which the notification will be sent.";
      };

      email.mailTo = mkOption {
        type = types.str;
        default = null;
        description = "Email address to which the service status will be mailed.";
      };

      email.mailFrom = mkOption {
        type = types.str;
        default = null;
        description = "Email address from which the service status will be mailed.";
      };
    };

    systemd.services = mkOption {
      type =
        with types;
        attrsOf (submodule {
          config.onFailure = optional cfg.enable "notify@%n.service";
        });
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.method != "libnotify" || cfg.libnotify.user != null;
        message = "You need to specify a user";
      }
      {
        assertion = cfg.method != "email" || (cfg.email.mailTo != null && cfg.email.mailFrom != null);
        message = "You need to specify a sender and a receiver";
      }
    ];

    systemd.services."notify@" =
      lib.recursiveUpdate
        {
          onFailure = lib.mkForce [ ];
          unitConfig = {
            StartLimitIntervalSec = "15m";
            StartLimitBurst = 1;
          };
          serviceConfig = {
            Type = "oneshot";
            ExecCondition = "${checkConditions} %i";
          };
        }
        (
          optionalAttrs (cfg.method == "libnotify") {
            description = "Desktop notifications for %i service failure";
            environment = {
              DISPLAY = ":0";
              INSTANCE = "%i";
            };
            script = ''
              export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u '${cfg.libnotify.user}')/bus"
              ${pkgs.libnotify}/bin/notify-send --app-name="$INSTANCE" --urgency=critical \
                "Service '$INSTANCE' failed" \
                "$(journalctl -n 6 -o cat -u $INSTANCE)"
            '';
            serviceConfig.User = cfg.libnotify.user;
          }
          // optionalAttrs (cfg.method == "email") {
            description = "E-Mail notifications for %i service failure";
            serviceConfig.ExecStart = "${sendmail} %i";
          }
        );
  };
}
