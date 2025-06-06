_:

{
  imports = [ ../modules/cosmic ];

  programs.cosmic = {
    enable = true;
    settings = {
      "com.system76.CosmicTk".v1 = {
        icon_theme = "Cosmic";
      };
      "com.system76.CosmicFiles".v1 = {
        tab.show_hidden = true;
        favorites = [
          "Home"
          "Documents"
          "Downloads"
          "Music"
          "Pictures"
          "Videos"
          ''Path("/home/felschr/dev")''
          ''Path("/home/felschr/dev/work")''
          ''Path("/home/felschr/dev/mscs")''
          ''Path("/home/felschr/Documents/CU Boulder MSCS")''
        ];
      };
      "com.system76.CosmicAppletAudio".v1 = {
        show_media_controls_in_top_panel = true;
      };
    };
  };
}
