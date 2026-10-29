{ ... }:

{
  # Keeps heavy builds (autoUpgrade, deploy-rs, Forgejo CI) from freezing the host.
  # All of them go through the nix daemon, so a single slice bounds all of them.
  systemd.slices.nix-builds.sliceConfig = {
    CPUWeight = 50;
    IOWeight = 50;
    MemoryHigh = "50%";
    MemoryMax = "70%";
  };

  systemd.services.nix-daemon.serviceConfig.Slice = "nix-builds.slice";
  systemd.services.nixos-upgrade.serviceConfig.Slice = "nix-builds.slice";
  systemd.services.gitea-runner-local.serviceConfig.Slice = "nix-builds.slice";

  # oomd is enabled by default but watches no slice, so it never acts; this
  # catches hogs outside nix-builds.slice (restic, jellyfin, paperless, ...)
  systemd.oomd.enableSystemSlice = true;

  # large dirty page pools cause multi-second stalls while the store is written
  # to btrfs (compress-force=zstd:1); keep reclaim ahead of a memory hog
  boot.kernel.sysctl = {
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    "vm.min_free_kbytes" = 262144;
  };
}
