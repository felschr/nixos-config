{ config, lib, pkgs, ... }:

{
  services.easyeffects.enable = true;

  # based on https://gist.github.com/MateusRodCosta/a10225eb132cdcb97d7c458526f93085
  xdg.configFile."easyeffects/input/optimised.json".text = builtins.toJSON {
    input = {
      blocklist = [ ];
      compressor = {
        attack = 20.0;
        boost-amount = 6.0;
        boost-threshold = -72.0;
        bypass = false;
        hpf-frequency = 10.0;
        hpf-mode = "off";
        input-gain = 0.0;
        knee = -6.0;
        lpf-frequency = 20000.0;
        lpf-mode = "off";
        makeup = 0.0;
        mode = "Downward";
        output-gain = 0.0;
        ratio = 4.0;
        release = 100.0;
        release-threshold = -120.0;
        sidechain = {
          lookahead = 0.0;
          mode = "RMS";
          preamp = 0.0;
          reactivity = 10.0;
          source = "Middle";
          type = "Feed-forward";
        };
        threshold = -12.0;
      };
      gate = {
        attack = 10.0;
        bypass = false;
        curve-threshold = -24.0;
        curve-zone = -6.0;
        hpf-frequency = 10.0;
        hpf-mode = "off";
        hysteresis = false;
        hysteresis-threshold = -12.0;
        hysteresis-zone = -6.0;
        input-gain = 0.0;
        lpf-frequency = 20000.0;
        lpf-mode = "off";
        makeup = 0.0;
        output-gain = 0.0;
        reduction = -12.0;
        release = 100.0;
        sidechain = {
          input = "Internal";
          lookahead = 0.0;
          mode = "RMS";
          preamp = 0.0;
          reactivity = 10.0;
          source = "Middle";
        };
      };
      limiter = {
        alr = false;
        alr-attack = 5.0;
        alr-knee = 0.0;
        alr-release = 50.0;
        attack = 5.0;
        bypass = false;
        dithering = "None";
        external-sidechain = false;
        gain-boost = true;
        input-gain = 0.0;
        lookahead = 5.0;
        mode = "Herm Thin";
        output-gain = 0.0;
        oversampling = "None";
        release = 5.0;
        sidechain-preamp = 0.0;
        stereo-link = 100.0;
        threshold = 0.0;
      };
      plugins_order = [ "gate" "compressor" "rnnoise" "limiter" ];
      rnnoise = {
        bypass = false;
        input-gain = 0.0;
        model-path = "";
        output-gain = 0.0;
      };
    };
  };

  xdg.configFile."easyeffects/autoload/input/alsa_input.usb-Blue_Microphones_Yeti_Stereo_Microphone_REV8-00.analog-stereo:analog-input-mic.json".text =
    builtins.toJSON {
      device =
        "alsa_input.usb-Blue_Microphones_Yeti_Stereo_Microphone_REV8-00.analog-stereo";
      device-description = "Yeti Stereo Microphone Analog Stereo";
      device-profile = "analog-input-mic";
      preset-name = "optimised";
    };
}
