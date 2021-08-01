{ config, lib, pkgs, ... }:

{
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    media-session.config.bluez-monitor.rules = [
      {
        matches = [{ "device.name" = "~bluez_card.*"; }];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            "bluez5.msbc-support" = true;
            "bluez5.sbc-xq-support" = true;
          };
        };
      }
      {
        matches = [
          { "node.name" = "~bluez_input.*"; }
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = { "node.pause-on-idle" = false; };
      }
    ];
  };
}
