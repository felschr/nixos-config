# Persistent herdr agent workspace server for this machine (imported only by
# hosts where the herd should always run). The `herdr` package itself is
# installed for users via home/ai.nix.
{
  inputs,
  pkgs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  herdr = inputs.llm-agents.packages.${system}.herdr;

  # Pinned everywhere (services + interactive shells) so that agents spawned
  # inside herdr panes and collie always reach the same server socket.
  socketPath = "%h/.config/herdr/herdr.sock";
in
{
  home.sessionVariables.HERDR_SOCKET_PATH = "${socketPath}";

  # herdr's agent hooks (session reporting) need python3; without it they
  # exit silently. Must be on the PATH the *agent shells* run with.
  home.packages = [ pkgs.python3 ];

  # Keep user services running after logout / across reboots: the herd stays
  # up when you SSH away. Home Manager has no linger option here, so the host
  # sets users.users.felschr.linger (see this module's importing host config).

  systemd.user.services.herdr = {
    Unit = {
      Description = "herdr: agent workspace server";
      After = [ "default.target" ];
      # A phone-only operator can't run `systemctl reset-failed`.
      StartLimitIntervalSec = 0;
    };
    Service = {
      Type = "simple";
      # headless server for supervised/service-style setups (herdr docs)
      ExecStart = "${herdr}/bin/herdr server";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = "HERDR_SOCKET_PATH=${socketPath}";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
