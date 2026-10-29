{ lib, ... }:

# Hardware watchdog safety net for a headless box.
#
# This does *not* fix the memory-thrash freeze: PID 1 stays small and keeps
# petting the watchdog while builds livelock the machine (that needs the
# cgroup limits in ./builds.nix plus oomd). What it does catch are the failure
# modes where nothing recovers on its own:
#   - a wedged kernel / hard lockup
#   - PID 1 stuck in D state on an I/O stall (btrfs writeback, hung NVMe)
#   - a shutdown that never completes (LUKS teardown, a service that won't die)
{
  systemd.settings.Manager = {
    # systemd pets at half this interval; 60s leaves room for legitimately
    # slow but recoverable stalls without rebooting the box
    RuntimeWatchdogSec = "60s";
    # only arms the watchdog once systemd-shutdown takes over, so it costs a
    # hung reboot at most 10 minutes instead of leaving the host dark
    RebootWatchdogSec = "10min";
  };
}
