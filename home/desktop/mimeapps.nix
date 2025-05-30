{ pkgs, lib, ... }:

with lib;
let
  browsers = [
    "mullvad-browser.desktop"
    "mullvad-browser-work.desktop"
    "firefox.desktop"
    "firefox-work.desktop"
    "tor-browser.desktop"
  ];

  defaultApps = {
    text = [ "org.gnome.gedit.desktop" ];
    image = [ "org.gnome.Loupe.desktop" ];
    audio = [ "io.github.celluloid_player.Celluloid.desktop" ];
    video = [ "io.github.celluloid_player.Celluloid.desktop" ];
    directory = [
      "nautilus.desktop"
      "org.gnome.Nautilus.desktop"
    ];
    mail = [ "re.sonny.Junction.desktop" ] ++ browsers;
    calendar = [ "re.sonny.Junction.desktop" ] ++ browsers;
    browser = [ "re.sonny.Junction.desktop" ] ++ browsers;
    office = [ "libreoffice.desktop" ];
    pdf = [ "re.sonny.Junction.desktop" ] ++ browsers;
    ebook = [ "com.github.johnfactotum.Foliate.desktop" ];
    magnet = [ "transmission-gtk.desktop" ];
    signal = [ "signal.desktop" ];
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
    calendar = [
      "text/calendar"
      "x-scheme-handler/webcal"
    ];
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
      "application/rtf"
    ];
    pdf = [ "application/pdf" ];
    ebook = [ "application/epub+zip" ];
    magnet = [ "x-scheme-handler/magnet" ];
    signal = [ "signal.desktop" ];
  };

  associations =
    with lists;
    listToAttrs (
      flatten (mapAttrsToList (key: map (type: attrsets.nameValuePair type defaultApps."${key}")) mimeMap)
    );

  noCalibre =
    let
      mimeTypes = [
        "application/pdf"
        "application/vnd.oasis.opendocument.text"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "text/html"
        "text/x-markdown"
      ];
      desktopFiles = [
        "calibre-ebook-edit.desktop"
        "calibre-ebook-viewer.desktop"
        "calibre-gui.desktop"
      ];
    in
    lib.zipAttrs (map (d: lib.genAttrs mimeTypes (_: d)) desktopFiles);
in
{
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.associations.added = associations;
  xdg.mimeApps.associations.removed = noCalibre;
  xdg.mimeApps.defaultApplications = associations;

  home.packages = with pkgs; [ junction ];

  home.sessionVariables = {
    # prevent wine from creating file associations
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";
  };
}
