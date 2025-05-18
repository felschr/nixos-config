{ pkgs, ... }:

let
  prettier = parser: {
    command = "prettier";
    args = [
      "--parser"
      parser
    ];
  };
  typescriptLanguageServers = [
    {
      name = "typescript-language-server";
      except-features = [ "format" ];
    }
    "vscode-eslint-language-server"
  ];
in
{
  # HINT for direnv to work needs to be started from project folder
  programs.helix = {
    enable = true;
    package = pkgs.unstable.helix;
    languages.language = [
      {
        name = "javascript";
        language-servers = typescriptLanguageServers;
        # TODO also configure eslint for diagnostics
        # formatter.command = ["eslint_d"];
        # formatter.args = ["--fix"];
        formatter = prettier "typescript";
        auto-format = true;
      }
      {
        name = "jsx";
        language-servers = typescriptLanguageServers;
        formatter = prettier "typescript";
        auto-format = true;
      }
      {
        name = "typescript";
        language-servers = typescriptLanguageServers;
        formatter = prettier "typescript";
        auto-format = true;
      }
      {
        name = "tsx";
        language-servers = typescriptLanguageServers;
        formatter = prettier "typescript";
        auto-format = true;
      }
      {
        name = "python";
        language-servers = [ "pyright" ];
      }
      {
        name = "nix";
        # HINT `nix fmt` is a bit slow
        formatter.command = "nixfmt";
        language-servers = [
          "nixd"
          "statix"
        ];
        auto-format = true;
      }
      {
        name = "nickel";
        formatter.command = "topiary";
        auto-format = true;
      }
      {
        name = "protobuf";
        formatter.command = "buf";
        formatter.args = [
          "format"
          "-w"
        ];
        language-servers = [
          "bufls"
          "buf-lint"
        ];
      }
      {
        name = "graphql";
        formatter = prettier "graphql";
        auto-format = true;
      }
      {
        name = "toml";
        auto-format = true;
      }
      {
        name = "json";
        formatter = prettier "json";
      }
      {
        name = "yaml";
        formatter = prettier "yaml";
        auto-format = true;
      }
      {
        name = "css";
        formatter = prettier "css";
        auto-format = true;
      }
      {
        name = "html";
        formatter = prettier "html";
        auto-format = true;
      }
      {
        name = "markdown";
        formatter = prettier "markdown";
        auto-format = true;
      }
      # newer versions of bash-language-server already integrate shfmt
      {
        name = "bash";
        formatter = {
          command = "shfmt";
          args = [
            "-i"
            "2"
            "-"
          ];
        };
        auto-format = true;
      }
    ];
    languages.language-server = {
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
      statix = {
        command = "efm-langserver";
        config = {
          languages = {
            nix = [
              {
                # https://github.com/creativenull/efmls-configs-nvim/blob/ddc7c542aaad21da594edba233c15ae3fad01ea0/lua/efmls-configs/linters/statix.lua
                lintCommand = "statix check --stdin --format=errfmt";
                lintStdIn = true;
                lintIgnoreExitCode = true;
                lintFormats = [ "<stdin>>%l:%c:%t:%n:%m" ];
                rootMarkers = [
                  "flake.nix"
                  "shell.nix"
                  "default.nix"
                ];
              }
            ];
          };
        };
      };
      buf-lint = {
        command = "efm-langserver";
        config.languages.protobuf = [
          {
            lintCommand = "buf lint --path";
            rootMarkers = [ "buf.yaml" ];
          }
        ];
      };
      nixd.command = "nixd";
      # does not support formatting
      vscode-eslint-language-server = {
        # https://github.com/helix-editor/helix/issues/3520#issuecomment-1439987347
        command = "vscode-eslint-language-server";
        args = [ "--stdio" ];
        config = {
          validate = "on";
          experimental.useFlatConfig = false; # required for old configs
          rulesCustomizations = [ ];
          run = "onType";
          problems.shortenToSingleLine = false;
          nodePath = "";
          quiet = false;
          format = true;
          codeAction = {
            disableRuleComment = {
              enable = true;
              location = "separateLine";
            };
            showDocumentation.enable = true;
          };
          codeActionOnSave.mode = "problems";
          workingDirectory.mode = "auto";
        };
      };
      pyright = {
        command = "pyright-langserver";
        args = [ "--stdio" ];
      };
      lua-language-server = {
        config = {
          runtime = {
            version = "LuaJIT";
            path = [
              "?.lua"
              "?/init.lua"
            ];
          };
        };
      };
    };
    settings = {
      theme = "dark_plus";
      editor = {
        color-modes = true;
        cursor-shape.insert = "bar";
        completion-trigger-len = 1;
        line-number = "relative";
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
      keys = {
        normal = {
          "H" = "goto_line_start";
          "L" = "goto_line_end";
        };
        select = {
          "H" = "goto_line_start";
          "L" = "goto_line_end";
        };
        insert = {
          "C-space" = "completion";
        };
      };
    };
  };
}
