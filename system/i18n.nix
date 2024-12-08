{ config, pkgs, ... }:

{
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "en_DK.UTF-8";
      LC_MONETARY = "en_IE.UTF-8";
    };
    supportedLocales = [ "all" ];
    inputMethod.enable = true;
    inputMethod.type = "ibus";
    inputMethod.ibus.engines = with pkgs.ibus-engines; [
      uniemoji
      mozc
    ];
  };

  time.timeZone = "Europe/Berlin";
}
