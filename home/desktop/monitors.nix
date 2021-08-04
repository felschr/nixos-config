{ config, pkgs, ... }:

{
  xdg.configFile."monitors.xml".source = ./monitors.xml;
}
