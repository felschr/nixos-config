{ lib, ... }:

{
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

  # needs access to /proc/cpuinfo
  systemd.services."wyoming-faster-whisper-en".serviceConfig.ProcSubset =
    lib.mkForce "all";
}
