{ pkgs, ... }:

{
  # @TODO for direnv to work needs to be started from project folder
  programs.helix = {
    enable = true;
    package = pkgs.unstable.helix;
    languages.language = [
      { name = "rust"; }
      {
        name = "nix";
        formatter.command = "nixfmt";
      }
      {
        name = "nickel";
        formatter.command = "topiary";
      }
    ];
    languages.language_server = {
      rust-analyzer = {
        config.rust-analyzer = {
          cargo.buildScripts.enable = true;
          checkOnSave.command = "clippy";
          procMacro.enable = true;
          procMacro.ignored = {
            # See https://github.com/rust-lang/rust-analyzer/issues/15800
            # core = [ "cfg_eval" ];
            # cfg_eval = [ "cfg_eval" ];
          };
        };
      };
    };
    settings = {
      theme = "github_dark";
      editor = {
        color-modes = true;
        cursor-shape.insert = "bar";
        completion-trigger-len = 1;
        statusline = {
          left = [
            "mode"
            "version-control"
            "spinner"
            "file-name"
            "file-modification-indicator"
          ];
          right = [
            "diagnostics"
            "file-encoding"
            "file-line-ending"
            "file-type"
            "selections"
            "position"
          ];
        };
      };
      # @TODO try helix-vim
      keys = {
        normal = {
          "H" = "goto_line_start";
          "L" = "goto_line_end";
        };
        select = {
          "H" = "goto_line_start";
          "L" = "goto_line_end";
        };
      };
    };
  };
}
