{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
  skillSources = {
    agent-browser = pkgs.fetchFromGitHub {
      owner = "vercel-labs";
      repo = "agent-browser";
      rev = "dac13bb87468fe9d74a040d862720f6cc17a9565";
      hash = "sha256-AGkOphWUxVAZ5YUQKa1LhGWmQC0UNzrme/ln8EC2bCQ=";
    };
    anthropic-skills = pkgs.fetchFromGitHub {
      owner = "anthropics";
      repo = "skills";
      rev = "dbd4588f9e1033efb41dad4bef2f7947c8993d44";
      hash = "sha256-+UIqBnzyeIOvJSKYaDaE3GYPEpLw7qQqyUw5S971AfU=";
    };
    atvari-skills = pkgs.fetchFromGitHub {
      owner = "atvari-eu";
      repo = "skills";
      rev = "f3b6fb006855d1c260558e44c93d5eb94f8ee8ac";
      hash = "sha256-C0pvnLpU394IsCjj+rhjbLO79xEDR+KcbAkXaHcPjAw=";
    };
    nix-skills = pkgs.fetchFromGitHub {
      owner = "atvari-eu";
      repo = "nix-skills";
      rev = "9b71335b97153ae4065622b9e0b814146f7860f6";
      hash = "sha256-YOIx0ZOxdoWVG8/utffZ7BGivQ5ZGOlbmlURXWCJD6M=";
    };
    ponytail = pkgs.fetchFromGitHub {
      owner = "dietrichgebert";
      repo = "ponytail";
      rev = "16352ac229eb08a9598dcae48fe9f2b342567d86";
      hash = "sha256-IJlhfkdXI6pMZZCZO7XBRg88LBiNfzc5Gnm4ofGybL8=";
    };
    web-quality-skills = pkgs.fetchFromGitHub {
      owner = "addyosmani";
      repo = "web-quality-skills";
      rev = "afa8da942115f2961fdbfa80807ea0b232ff6c00";
      hash = "sha256-RW+30OFUYxNO/SqPJ/bmwAn965GOoxjeuKBMFBtESHE=";
    };
    # typesafe-skills — TypeSafe AI's official agent skill for building with
    # System One decision models (question design, patterns, cookbooks, live
    # docs links, SDKs). Deployment facts for OUR endpoint (OpenCode Console
    # serves Jev) live in the repo-local `system-one` skill below.
    typesafe-skills = pkgs.fetchFromGitHub {
      owner = "typesafe-ai";
      repo = "skills";
      rev = "65a39f393687675ce170e6094757de20370365b9";
      hash = "sha256-Lh2Y90TFv+njKqo/g5WXEHw0Rk1jQSH5POqKtrvy5kM=";
    };
  };

  # omp extensions installed into ~/.omp/agent/extensions/ (see home.file below).
  # omp natively discovers direct *.ts files and package directories (whose
  # package.json declares omp.extensions), and rewrites the legacy
  # @earendil-works/pi-* imports these use onto the host-bundled copies
  # (docs/extension-loading.md in the omp repo).
  ompExtensions = {
    # pi-think-panel: live scrolling view of the latest model reasoning above the
    # editor (1/3/5/7 lines, /think-panel to configure).
    pi-think-panel = pkgs.fetchFromGitHub {
      owner = "fan56";
      repo = "pi-think-panel";
      rev = "1d52902d9b885cf29925baa49556c642adba10fe"; # v0.3.3
      hash = "sha256-oWgJxhrVLMJOKmwq+xjBGV3s6QPZwtkwROy/r0xhp9g=";
    };
  };

  # Vendored omp extension packages (release tags), linked as whole directories
  # so their package.json manifest resolves the extension entry.
  ompExtensionPackages = {
    # pi-background-run: background-job panel above the editor + `⏳ N running`
    # status line (covers omp's native auto-backgrounded jobs), /bgstatus,
    # /bgtail, /bgkill, /bgclean, plus the bgrun/bgtail/bggrep agent tools.
    pi-background-run = pkgs.fetchFromGitHub {
      owner = "stablekernel";
      repo = "pi-background-run";
      rev = "9350fae696c3306ce5a88f8d67cb03a04cf13a70"; # v0.8.0
      hash = "sha256-95DMkHfYRqKEW1FC4fKk3SRLMhQ9O6NSz3mFuopVr6Y=";
    };
  };

  # Skills bundled with vendored omp extension packages, planted into the
  # omp user-level skills root (~/.omp/agent/skills) that omp scans natively.
  ompExtensionSkills = lib.genAttrs [
    "run-bg"
    "digest-config"
  ] (name: "${ompExtensionPackages.pi-background-run}/skills/${name}");

  skills = {
    agent-browser = "${skillSources.agent-browser}/skills/agent-browser";
    atvari-copyright = "${skillSources.atvari-skills}/skills/atvari-copyright";
    ci-agents = "${skillSources.atvari-skills}/skills/ci-agents";
    conventional-commits = "${skillSources.atvari-skills}/skills/conventional-commits";
    find-skills = "${skillSources.nix-skills}/skills/find-skills";
    nix-flake = "${skillSources.nix-skills}/skills/nix-flake";
    nix-hash = "${skillSources.nix-skills}/skills/nix-hash";
    nix-init = "${skillSources.nix-skills}/skills/nix-init";
    pdf = "${skillSources.anthropic-skills}/skills/pdf";
    ponytail = "${skillSources.ponytail}/skills/ponytail";
    seo = "${skillSources.web-quality-skills}/skills/seo";
    skill-creator = "${skillSources.anthropic-skills}/skills/skill-creator";
    auto-system-one = "${skillSources.atvari-skills}/skills/auto-system-one";
    system-one = "${skillSources.atvari-skills}/skills/system-one";
    terranix = "${skillSources.nix-skills}/skills/terranix";
    typesafe-ai = "${skillSources.typesafe-skills}/skills/typesafe-ai";
  };

  # Shared-root set: omits the jev skills (see the opencode comment below).
  agentSkills = builtins.removeAttrs skills [
    "system-one"
    "auto-system-one"
  ];

  # jev — terminal client for the System One decision endpoint served by the
  # OpenCode Console provider (see the system-one skill). Reads a request
  # body without "model"/auth on stdin, adds the model + Console key, POSTs,
  # and prints {answers, usage}. The key is read at call time from
  # opencode's own auth store; it is never exported or stored anywhere.
  #
  # Removability: jev-native consumers (opencode via the opencode-system-one
  # plugin, omp via its built-in TypeSafeJudge) never invoke this. The
  # remaining consumers are the agents that still load the system-one skill
  # (claude, goose) - this CLI is their only key source (`auth.json`) - plus
  # interactive terminal use. Drop it in the same sweep that removes or
  # natively replaces the skill on those agents, never before.
  jevCli = pkgs.writeShellScriptBin "jev" ''
    set -euo pipefail

    model="''${JEV_MODEL:-jev-1.13}"
    auth="''${OPENCODE_AUTH:-$HOME/.local/share/opencode/auth.json}"

    if [ ! -f "$auth" ]; then
      echo "jev: auth file not found: $auth (connect once via /connect)" >&2
      exit 1
    fi
    key="$(jq -r '.opencode.key // empty' "$auth")"
    if [ -z "$key" ]; then
      echo "jev: no OpenCode Console key in $auth (run /connect once)" >&2
      exit 1
    fi

    response="$(jq -c --arg m "$model" '.model //= $m' |
      curl -sS --max-time 60 \
        -H "Authorization: Bearer $key" \
        -H 'Content-Type: application/json' \
        --data-binary @- \
        https://opencode.ai/inference/systemone/v1/systemone)"

    if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
      echo "$response" | jq -r '"jev upstream error: \(.error.message // .error.type // "unknown")"' >&2
      exit 1
    fi
    if echo "$response" | jq -e '.answers | type == "object"' >/dev/null 2>&1; then
      echo "$response" | jq '{answers, usage}'
    else
      echo "$response" >&2
      echo "jev: malformed System One response" >&2
      exit 1
    fi
  '';
in
{
  imports = [
    ./modules/goose.nix
    ./modules/omp.nix
  ];

  programs.opencode.enable = true;
  programs.opencode.package = inputs.llm-agents.packages.${system}.opencode2;
  # Declarative runtime config: settings reimplements ~/.config/opencode/opencode.json
  # wholesale (the HM module replaces the file). The switch makes that file a
  # read-only store symlink, so runtime self-persisting tweaks (saved model,
  # theme) stop surviving. Plugin updates: bump the pin above.
  programs.opencode.settings = {
    providers = {
      munito = {
        name = "Munito";
        env = [ "MUNITO_API_KEY" ];
        package = "@opencode/ai/providers/openai-compatible";
        settings.baseURL = "https://api.eu.munito.ai/inference/v1";
        models = {
          "aleph-alpha/kolibri-1".name = "Kolibri 1";
          "deepseek-ai/deepseek-v4-flash".name = "DeepSeek V4 Flash";
          "google/gemma-4-12b".name = "Gemma 4 12B";
          "mistralai/mistral-small-4-119b-2603".name = "Mistral Small 4";
          "qwen/qwen3.6-35b-a3b".name = "Qwen3.6 35B A3B";
          "qwen/qwen3.8-27b".name = "Qwen3.8 27B";
          "zai-org/glm-5.3-flash".name = "GLM-5.3 Flash";
        };
      };
    };
    mcp.servers = {
      db-fahrplan = {
        type = "local";
        command = [
          "nix"
          "shell"
          "nixpkgs#uv"
          "-c"
          "uvx"
          "db-fahrplan-mcp"
        ];
        timeout.startup = 120000;
      };
      opentofu = {
        type = "remote";
        url = "https://mcp.opentofu.org/mcp";
        enabled = true;
      };
      munito = {
        type = "remote";
        url = "https://api.munito.ai/mcp/v1";
      };
    };
    plugins = [
      {
        package = "github:atvari-eu/opencode-system-one#2a4a4703b06e4b27fd8a8cef90d440d5330d1896";
        options = {
          provider = "opencode"; # jev models live on the Console provider
          model = "jev-1.13";
          screen = {
            enabled = true;
            mode = "annotate";
            tools = "all"; # screen every tool result, not just fetched pages
          };
          scrub.enabled = true;
          tools = true;
          commands = true;
          cache = true;
          auto = {
            sources = {
              favorites = true;
              opencode.plan = "go";
            };
          };
          effort.auto = true; # per-prompt thinking level; pairs with auto
          doneCheck.auto = true; # completion probe when the session goes idle
          find.enabled = true; # jev_find: jev-backed semantic code search
          compaction = {
            enabled = true;
            mode = "replace";
            # compact at idle: jev passes are ~free, big prompts are not
            auto.tokens = 60000;
          };
          approvals.mode = "auto";
          approvals.actions = [
            "shell"
            "edit"
          ];
          # enact marginal verdicts too - fewer asks, slightly riskier
          approvals.minConfidence = 0.70;
          approvals.bypass = [
            {
              action = "shell";
              resource = "git status *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "git log *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "git diff *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "git branch *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "git show *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "ls *";
              effect = "allow";
            }
            {
              # routine, workspace-local; standard practice to allow
              action = "shell";
              resource = "git commit *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "bun test *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "shellcheck *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "nixfmt *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "nix fmt *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "nix search *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "nix eval *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "nix flake show *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "nix doctor *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "nix why-depends *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "nix store verify *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "nix store path-info *";
              effect = "allow";
            }
            {
              action = "shell";
              resource = "nix store *";
              effect = "ask";
            }
            {
              action = "shell";
              resource = "nixos-rebuild *";
              effect = "ask";
            }
            {
              action = "shell";
              resource = "nix-collect-garbage *";
              effect = "ask";
            }
            {
              action = "shell";
              resource = "nix flake update *";
              effect = "ask";
            }
            {
              action = "shell";
              resource = "git push *";
              effect = "ask";
            }
          ];
        };
      }
    ];
    permissions = [
      {
        action = "edit";
        resource = "*";
        effect = "allow";
      }
      {
        action = "external_directory";
        resource = "*";
        effect = "ask";
      }
      {
        action = "shell";
        resource = "*";
        effect = "ask";
      }
    ];
  };

  # Skill consumers that integrate jev natively do not use these skills: OpenCode
  # has the opencode-system-one plugin (hooks, tools, routing, `jev_*` tool
  # descriptions), and omp has its built-in TypeSafeJudge (providers.judgment).
  # Plugin-less agents keep them through their own roots instead: claude via
  # programs.claude-code.skills; goose runs without them.
  programs.opencode.skills = builtins.removeAttrs skills [
    "system-one"
    "auto-system-one"
  ];

  programs.claude-code.enable = true;
  programs.claude-code.package = inputs.llm-agents.packages.${system}.claude-code;
  programs.claude-code.skills = skills;

  programs.goose.enable = true;
  programs.goose.package = inputs.llm-agents.packages.${system}.goose-cli;

  programs.omp.enable = true;
  programs.omp.package = inputs.llm-agents.packages.${system}.omp;

  # Thinking blocks visible by default; Ctrl+T hides the full thinking inline.
  # OpenCode-flavored look: bordered box composer instead of flat band, footer
  # on terminal background with plain text separators.
  programs.omp.settings = {
    hideThinkingBlock = false;
    statusLine.compactThinkingLevel = false;

    theme.dark = "anthracite";
    composer.shape = "box";
    statusLine.transparent = true;
    statusLine.separator = "slash";

    # Safety net: omp also scans ~/.agents/skills.
    skills.ignoredSkills = [
      "system-one"
      "auto-system-one"
    ];
  };

  home.packages = [
    inputs.llm-agents.packages.${system}.agentsview
    inputs.llm-agents.packages.${system}.ck
    jevCli
  ];

  # goose & omp both discover Agent Skills (SKILL.md) from ~/.agents/skills,
  # the user-global location of the Agent Skills spec, by default.
  # omp also scans ~/.omp/agent/skills as its user-level skills root.
  home.file =
    lib.mapAttrs' (
      name: src: (lib.nameValuePair (".agents/skills/${name}") ({ source = src; }))
    ) agentSkills
    // lib.mapAttrs' (
      name: src:
      lib.nameValuePair ".omp/agent/extensions/${name}.ts" {
        source = "${src}/extensions/${name}.ts";
      }
    ) ompExtensions
    // lib.mapAttrs' (
      name: src:
      lib.nameValuePair ".omp/agent/extensions/${name}" {
        source = src;
        recursive = true;
      }
    ) ompExtensionPackages
    // lib.mapAttrs' (
      name: src:
      lib.nameValuePair ".omp/agent/skills/${name}" {
        source = src;
      }
    ) ompExtensionSkills;
}
