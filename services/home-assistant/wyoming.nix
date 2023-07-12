{ pkgs, inputs, ... }:

{
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/audio/wyoming/piper.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/audio/wyoming/faster-whisper.nix"
  ];

  nixpkgs.overlays = [
    (final: prev: {
      inherit (pkgs.unstable) wyoming-piper wyoming-faster-whisper piper-tts;
    })
  ];

  services.wyoming.piper = {
    servers = {
      "en" = {
        enable = true;
        # see https://github.com/rhasspy/rhasspy3/blob/master/programs/tts/piper/script/download.py
        voice = "en-gb-southern_english_female-low";
        uri = "tcp://0.0.0.0:10200";
        speaker = 0;
      };
    };
  };

  services.wyoming.faster-whisper = {
    servers = {
      "en" = {
        enable = true;
        # see https://github.com/rhasspy/rhasspy3/blob/master/programs/asr/faster-whisper/script/download.py
        model = "tiny-int8";
        language = "en";
        uri = "tcp://0.0.0.0:10300";
        device = "cpu";
      };
    };
  };
}
