{ pkgs, ... }:

{
  services.easyeffects.enable = true;
  services.easyeffects.package = pkgs.easyeffects.override {
    # easyeffects speex integration doesn't work otherwise
    speexdsp = pkgs.speexdsp.overrideAttrs (old: {
      configureFlags = [ ];
    });
  };

  # based on https://gist.github.com/MateusRodCosta/a10225eb132cdcb97d7c458526f93085
  xdg.configFile."easyeffects/input/optimised.json".text = builtins.toJSON {
    input = {
      blocklist = [ ];
      plugins_order = [
        "rnnoise#0"
        "speex#0"
      ];
      "rnnoise#0" = {
        bypass = false;
        enable-vad = false;
        input-gain = 0.0;
        model-path = "";
        output-gain = 0.0;
        release = 20.0;
        vad-thres = 50.0;
        wet = 0.0;
      };
      "speex#0" = {
        bypass = false;
        enable-agc = true;
        enable-denoise = true;
        enable-dereverb = true;
        input-gain = 0.0;
        noise-suppression = -70;
        output-gain = 0.0;
        vad = {
          enable = true;
          probability-continue = 90;
          probability-start = 95;
        };
      };
    };
  };

  xdg.configFile."easyeffects/autoload/input/alsa_input.usb-Blue_Microphones_Yeti_Stereo_Microphone_REV8-00.analog-stereo:analog-input-mic.json".text =
    builtins.toJSON
      {
        device = "alsa_input.usb-Blue_Microphones_Yeti_Stereo_Microphone_REV8-00.analog-stereo";
        device-description = "Yeti Stereo Microphone Analog Stereo";
        device-profile = "analog-input-mic";
        preset-name = "optimised";
      };
}
