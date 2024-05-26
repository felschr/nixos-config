{ config, pkgs, ... }:

{
  imports = [
    ./lsp.nix
    ./dap.nix
    ./helix
    ./neovim
  ];

  home.packages = with pkgs; [
    fzf
    ripgrep
  ];

  home.sessionVariables.EDITOR = "hx";

  home.file.".editorconfig".text = ''
    [*]
    charset = utf-8
    indent_style = space
    indent_size = 2
    end_of_line = lf
    insert_final_newline = true
    trim_trailing_whitespace = true

    [*.md]
    insert_final_newline = false
    trim_trailing_whitespace = false
  '';
}
