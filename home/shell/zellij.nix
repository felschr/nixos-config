{
  pkgs,
  inputs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;

  # zj-radar classifies a pane by its argv, and every agent here starts through
  # `nono run -- <agent>`, which it does not see through (the rail reads
  # "nono run"). The CLI and the wasm share zj-radar-core, so both get patched.
  zjRadarPatched =
    pkg:
    pkg.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ../../pkgs/zj-radar-nono-wrapper.patch ];
    });
  zjRadar = {
    default = zjRadarPatched inputs.zj-radar.packages.${system}.default;
    zj-radar-cli = zjRadarPatched inputs.zj-radar.packages.${system}.zj-radar-cli;
  };
in
{
  programs.zellij.enable = true;
  programs.zellij.package = pkgs.unstable.zellij;
  programs.zellij.enableZshIntegration = true;
  programs.zellij.exitShellOnExit = true;
  programs.zellij.settings = {
    default_layout = "radar";
    default_mode = "normal";
    show_startup_tips = false;
    ui.pane_frames = {
      hide_session_name = true;
    };
    plugins = {
      tab-bar.path = "tab-bar";
      status-bar.path = "status-bar";
      strider.path = "strider";
      radar = {
        location = "file:~/.config/zellij/plugins/zj_radar.wasm";
        notify_when_focused = true;
      };
    };
  };

  # zj-radar's agent producers call `zj-radar notify`; wasm and CLI share the pin.
  # The rail's desktop notifications shell out to `notify-send` on PATH.
  home.packages = [
    zjRadar.zj-radar-cli
    pkgs.libnotify
  ];
  home.file.".config/zellij/plugins/zj_radar.wasm".source = "${zjRadar.default}/bin/zj_radar.wasm";

  # sidebar rail in every tab; new_tab_template needs a concrete pane (zellij#3247),
  # and the swap layouts keep Alt+[ / Alt+] cycling with the rail attached
  programs.zellij.layouts.radar = ''
    layout {
        default_tab_template {
            pane split_direction="vertical" {
                pane size=32 borderless=true {
                    plugin location="radar"
                }
                children
            }
            pane size=1 borderless=true {
                plugin location="compact-bar"
            }
        }

        new_tab_template {
            pane split_direction="vertical" {
                pane size=32 borderless=true {
                    plugin location="radar"
                }
                pane focus=true
            }
            pane size=1 borderless=true {
                plugin location="compact-bar"
            }
        }

        tab_template name="ui" {
            pane split_direction="vertical" {
                pane size=32 borderless=true {
                    plugin location="radar"
                }
                children
            }
            pane size=1 borderless=true {
                plugin location="compact-bar"
            }
        }

        swap_tiled_layout name="vertical" {
            ui max_panes=5 {
                pane split_direction="vertical" {
                    pane
                    pane { children; }
                }
            }
            ui max_panes=8 {
                pane split_direction="vertical" {
                    pane { children; }
                    pane { pane; pane; pane; pane; }
                }
            }
            ui max_panes=12 {
                pane split_direction="vertical" {
                    pane { children; }
                    pane { pane; pane; pane; pane; }
                    pane { pane; pane; pane; pane; }
                }
            }
        }

        swap_tiled_layout name="horizontal" {
            ui max_panes=4 {
                pane
                pane
            }
            ui max_panes=8 {
                pane {
                    pane split_direction="vertical" { children; }
                    pane split_direction="vertical" { pane; pane; pane; pane; }
                }
            }
            ui max_panes=12 {
                pane {
                    pane split_direction="vertical" { children; }
                    pane split_direction="vertical" { pane; pane; pane; pane; }
                    pane split_direction="vertical" { pane; pane; pane; pane; }
                }
            }
        }

        swap_tiled_layout name="stacked" {
            ui min_panes=5 {
                pane split_direction="vertical" {
                    pane
                    pane stacked=true { children; }
                }
            }
        }
    }
  '';
}
