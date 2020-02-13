{ config, pkgs, ... }:

{
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_MONETARY = "en_IE.UTF-8";
    };
    inputMethod.enabled = "ibus";
    inputMethod.ibus.engines = with pkgs.ibus-engines; [ uniemoji ];
  };
 
  time.timeZone = "Europe/Berlin";
}
