{ pkgs, ... }:

{
  programs.zellij.enable = true;
  programs.zellij.package = pkgs.unstable.zellij;
  programs.zellij.enableZshIntegration = true;
  programs.zellij.settings = {
    default_layout = "compact"; # or default
    default_mode = "normal";
    ui.pane_frames = {
      hide_session_name = true;
    };
    plugins = {
      tab-bar.path = "tab-bar";
      status-bar.path = "status-bar";
      strider.path = "strider";
    };
  };

  home.sessionVariables = {
    ZELLIJ_AUTO_EXIT = "true";
  };
}
