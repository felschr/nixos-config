{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.systemd.emailNotify;
  sendmail = pkgs.writeScript "sendmail" ''
    #!${pkgs.runtimeShell}

    ${pkgs.system-sendmail}/bin/sendmail -t <<ERRMAIL
    To: ${cfg.mailTo}
    From: ${cfg.mailFrom}
    Subject: Status of service $1
    Content-Transfer-Encoding: 8bit
    Content-Type: text/plain; charset=UTF-8
    $(systemctl status --full "$1")
    ERRMAIL
  '';
in {
  options = {
    systemd.emailNotify = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description =
          "Whether to enable email notification for failed services.";
      };

      mailTo = mkOption {
        type = types.str;
        default = null;
        description =
          "Email address to which the service status will be mailed.";
      };

      mailFrom = mkOption {
        type = types.str;
        default = null;
        description =
          "Email address from which the service status will be mailed.";
      };
    };

    systemd.services = mkOption {
      type = with types;
        attrsOf (submodule {
          config.onFailure = optional cfg.enable "email@%n.service";
        });
    };
  };

  config = mkIf cfg.enable {
    assertions = singleton {
      assertion = cfg.mailTo != null && cfg.mailFrom != null;
      message = "You need to specify a sender and a receiver";
    };

    systemd.services."email@" = {
      description = "Sends a status mail via sendmail on service failures.";
      onFailure = lib.mkForce [ ];
      serviceConfig = {
        ExecStart = "${sendmail} %i";
        Type = "oneshot";
      };
    };
  };
}
