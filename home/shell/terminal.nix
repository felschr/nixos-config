{ config, pkgs, lib, ... }:

with pkgs;
with lib;
let
  yamlToJSON = path:
    runCommand "yaml.json" { nativeBuildInputs = [ pkgs.ruby ]; } ''
      ruby -rjson -ryaml -e "puts YAML.load(ARGF).to_json" < ${path} > $out
    '';
in {
  programs.kitty = {
    enable = true;
    keybindings = {
      "ctrl+j" = "kitten pass_keys.py neighboring_window bottom ctrl+j";
      "ctrl+k" = "kitten pass_keys.py neighboring_window top    ctrl+k";
      "ctrl+h" = "kitten pass_keys.py neighboring_window left   ctrl+h";
      "ctrl+l" = "kitten pass_keys.py neighboring_window right  ctrl+l";
    };
    settings = {
      scrollback_pager = ''
        nvim -u NONE -c "syntax on" -c 'set ft=man nonumber nolist showtabline=0 foldcolumn=0 laststatus=0' -c "autocmd VimEnter * normal G" -c "map q :qa!<CR>" -c "set clipboard+=unnamedplus" -'';
    };
  };

  xdg.configFile."kitty/pass_keys.py".source =
    "${vimPlugins.vim-kitty-navigator}/pass_keys.py";
  xdg.configFile."kitty/neighboring_window.py".source =
    "${vimPlugins.vim-kitty-navigator}/neighboring_window.py";
}
