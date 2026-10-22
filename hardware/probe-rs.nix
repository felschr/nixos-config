{ pkgs, ... }:

{
  # udev rules for debug probes supported by probe-rs, e.g. to flash RMK
  # firmware on the Planck (STM32F303CC) via SWD with a debug probe.
  # https://probe.rs/docs/getting-started/probe-setup/ (GPLv2)
  services.udev.packages = [
    (pkgs.runCommand "probe-rs-udev-rules" { } ''
      install -D \
        ${
          pkgs.fetchurl {
            url = "https://probe.rs/files/69-probe-rs.rules";
            hash = "sha256-CfLqWaVzR2h2ZxhN/NETb2Zj38D/3BHrjrjZjzHatF0=";
          }
        } \
        $out/etc/udev/rules.d/69-probe-rs.rules
    '')
  ];

  users.groups.plugdev = { };
}
