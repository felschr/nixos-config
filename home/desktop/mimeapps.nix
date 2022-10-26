{ config, pkgs, lib, ... }:

with lib;
let
  defaultApps = {
    text = [ "org.gnome.gedit.desktop" ];
    image = [ "org.gnome.eog.desktop" ];
    audio = [ "io.github.celluloid_player.Celluloid.desktop" ];
    video = [ "io.github.celluloid_player.Celluloid.desktop" ];
    directory = [ "nautilus.desktop" "org.gnome.Nautilus.desktop" ];
    mail = [ "firefox.desktop" ];
    calendar = [ "firefox.desktop" ];
    browser = [ "firefox.desktop" ];
    office = [ "libreoffice.desktop" ];
    pdf = [ "firefox.desktop" ];
    magnet = [ "transmission-gtk.desktop" ];
    signal = [ "signal-desktop.desktop" ];
  };

  mimeMap = {
    text = [ "text/plain" ];
    image = [
      "image/bmp"
      "image/gif"
      "image/jpeg"
      "image/jpg"
      "image/png"
      "image/svg+xml"
      "image/tiff"
      "image/vnd.microsoft.icon"
      "image/webp"
    ];
    audio = [
      "audio/aac"
      "audio/mpeg"
      "audio/ogg"
      "audio/opus"
      "audio/wav"
      "audio/webm"
      "audio/x-matroska"
    ];
    video = [
      "video/mp2t"
      "video/mp4"
      "video/mpeg"
      "video/ogg"
      "video/webm"
      "video/x-flv"
      "video/x-matroska"
      "video/x-msvideo"
    ];
    directory = [ "inode/directory" ];
    mail = [ "x-scheme-handler/mailto" ];
    calendar = [ "text/calendar" "x-scheme-handler/webcal" ];
    browser = [
      "text/html"
      "x-scheme-handler/about"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/unknown"
    ];
    office = [
      "application/vnd.oasis.opendocument.text"
      "application/vnd.oasis.opendocument.spreadsheet"
      "application/vnd.oasis.opendocument.presentation"
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "application/msword"
      "application/vnd.ms-excel"
      "application/vnd.ms-powerpoint"
    ];
    pdf = [ "application/pdf" ];
    magnet = [ "x-scheme-handler/magnet" ];
    signal = [ "signal-desktop.desktop" ];
  };
in {
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = with lists;
    listToAttrs (flatten (mapAttrsToList (key: types:
      map (type: attrsets.nameValuePair (type) (defaultApps."${key}")) types)
      mimeMap));
}
