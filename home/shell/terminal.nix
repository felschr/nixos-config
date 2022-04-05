{ config, pkgs, lib, ... }:

with pkgs;
with lib; {
  # kitty
  programs.kitty = {
    enable = true;
    keybindings = let
      vimKittyBinding = bind:
        ''kitten pass_keys.py neighboring_window ${bind} "^.* - nvim$"'';
    in {
      "ctrl+h" = vimKittyBinding "left   ctrl+h";
      "ctrl+j" = vimKittyBinding "bottom ctrl+j";
      "ctrl+k" = vimKittyBinding "top    ctrl+k";
      "ctrl+l" = vimKittyBinding "right  ctrl+l";
    };
    settings = {
      allow_remote_control = "yes";
      # single_instance = "yes";
      listen_on = "unix:@mykitty";
      scrollback_pager = ''
        nvim -u NONE -c "syntax on" -c 'set ft=man nonumber nolist showtabline=0 foldcolumn=0 laststatus=0' -c "autocmd VimEnter * normal G" -c "map q :qa!<CR>" -c "set clipboard+=unnamedplus" -'';
    };
  };

  xdg.configFile."kitty/pass_keys.py".source =
    "${vimPlugins.nvim-kitty-navigator}/kitty/pass_keys.py";
  xdg.configFile."kitty/neighboring_window.py".source =
    "${vimPlugins.nvim-kitty-navigator}/kitty/neighboring_window.py";
}
