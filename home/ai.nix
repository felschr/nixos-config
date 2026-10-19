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
    # typesafe-skills: TypeSafe AI skills for building with System One/Jev
    typesafe-skills = pkgs.fetchFromGitHub {
      owner = "typesafe-ai";
      repo = "skills";
      rev = "65a39f393687675ce170e6094757de20370365b9";
      hash = "sha256-Lh2Y90TFv+njKqo/g5WXEHw0Rk1jQSH5POqKtrvy5kM=";
    };
  };

  # omp extensions for ~/.omp/agent/extensions/; omp rewrites legacy imports onto host-bundled copies
  ompExtensions = {
    # pi-think-panel: live reasoning panel above the editor
    pi-think-panel = pkgs.fetchFromGitHub {
      owner = "fan56";
      repo = "pi-think-panel";
      rev = "1d52902d9b885cf29925baa49556c642adba10fe"; # v0.3.3
      hash = "sha256-oWgJxhrVLMJOKmwq+xjBGV3s6QPZwtkwROy/r0xhp9g=";
    };
  };

  # Vendored as whole directories so their package.json manifest resolves the entry
  ompExtensionPackages = {
    # pi-background-run: background-job panel + /bgstatus, /bgtail, /bgkill, /bgclean + bgrun agent tools
    pi-background-run = pkgs.fetchFromGitHub {
      owner = "stablekernel";
      repo = "pi-background-run";
      rev = "9350fae696c3306ce5a88f8d67cb03a04cf13a70"; # v0.8.0
      hash = "sha256-95DMkHfYRqKEW1FC4fKk3SRLMhQ9O6NSz3mFuopVr6Y=";
    };
  };

  # omp extension skills, planted into omp's user-level skills root
  ompExtensionSkills = lib.genAttrs [
    "run-bg"
    "digest-config"
  ] (name: "${ompExtensionPackages.pi-background-run}/skills/${name}");

  skills = {
    # agent-browser = "${skillSources.agent-browser}/skills/agent-browser";
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

  # Shared ~ root (goose & omp); omits the jev skills (native integrations)
  agentSkills = builtins.removeAttrs skills [
    "system-one"
    "auto-system-one"
  ];

  # jev — System One endpoint client; key read from opencode's auth store at call
  # time. Consumed by agents that load the system-one skill (claude, goose).
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
let
  # opencode permission entry shorthand: (perm "shell" "git push *" "ask")
  perm = action: resource: effect: { inherit action resource effect; };
  # ... with operator context for the system-one effect
  permCtx =
    action: resource: effect: context:
    (perm action resource effect) // { inherit context; };
  # ... with a once-per-session agent-context hint
  permHint =
    action: resource: effect: hint:
    (perm action resource effect) // { inherit hint; };

  # nono — agent sandbox; version tracks the llm-agents pin
  nono = inputs.llm-agents.packages.${system}.nono;

  # opencode-nono — opencode under the nolabs-ai/opencode nono pack;
  # --standalone keeps tool execution inside the sandbox (test phase)
  opencodeNono = pkgs.writeShellScriptBin "opencode-nono" ''
    exec ${nono}/bin/nono run --profile nolabs-ai/opencode -- opencode2 --standalone "$@"
  '';

in
{
  imports = [
    ./modules/goose.nix
    ./modules/omp.nix
  ];

  programs.opencode.enable = true;
  programs.opencode.package = inputs.llm-agents.packages.${system}.opencode2;
  # settings replaces ~/.config/opencode/opencode.json wholesale; update the plugin by bumping its pin
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
          "perplexity-ai/pplx-decider-v1.2".name = "pplx-decider-v1.2 (preview)";
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
        package = "github:atvari-eu/opencode-system-one#158090a93d9ad076f5fd1de0a823a73ec105c6db";
        options = {
          # Console System One kept 422ing - route judgments through Munito (EU)
          provider = "munito";
          model = "perplexity-ai/pplx-decider-v1.2";
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
          # enact confident verdicts for every judged action; `ask` rules below pin must-prompt slices
          approvals.minConfidence = {
            approve = 0.60;
            deny = 0.80;
          };
          approvals.permissions = [
            (perm "shell" "git status *" "allow")
            (perm "shell" "git log *" "allow")
            (perm "shell" "git diff *" "allow")
            (perm "shell" "git branch *" "allow")
            (perm "shell" "git show *" "allow")
            (perm "shell" "ls *" "allow")
            (perm "shell" "git commit *" "allow")
            (perm "shell" "bun test *" "allow")
            (perm "shell" "shellcheck *" "allow")
            (perm "shell" "nixfmt *" "allow")
            (perm "shell" "nix fmt *" "allow")
            (perm "shell" "nix search *" "allow")
            (perm "shell" "nix eval *" "allow")
            (perm "shell" "nix flake show *" "allow")
            (perm "shell" "nix doctor *" "allow")
            (perm "shell" "nix why-depends *" "allow")
            (perm "shell" "nix store verify *" "allow")
            (perm "shell" "nix store path-info *" "allow")
            (perm "shell" "nix store *" "ask")
            (perm "shell" "nixos-rebuild *" "ask")
            (perm "shell" "nix-collect-garbage *" "ask")
            (perm "shell" "nix flake update *" "ask")
            (perm "shell" "git push *" "ask")
            (permHint "external_directory" "*" "ask"
              "for more than occasional access, prefer /cd to that directory"
            )
            (permCtx "edit" "*" "system-one"
              "Workspace-local edits are routine and fine. Refuse or hand to the operator any edit under secrets/ or of .env, *.key, *token* files - do not judge those yourself."
            )
            # read/grep/glob flow without jev approval (secret paths still gate); glob's resource is the pattern string, so path-side gating is the external_directory rule below.
            (perm "read" "*" "allow")
            (perm "grep" "*" "allow")
            (perm "glob" "*" "allow")
            # /tmp/opencode scratch area: file-tool access asserts external_directory "<dir>/*" first, so this paves read/glob/grep/edit there; /tmp itself and sibling dirs still ask
            (permHint "external_directory" "/tmp/opencode/*" "allow"
              "keep this session's scratch/temp files inside a session-specific subdirectory of /tmp/opencode (create one on first use, e.g. /tmp/opencode/<short-id>/), not directly in /tmp/opencode"
            )
            (perm "edit" "/tmp/opencode/*" "allow")
          ];
        };
      }
    ];
    permissions = [
      (perm "*" "*" "ask")
    ];
  };

  # claude/goose load the jev skills; opencode (plugin) & omp (TypeSafeJudge) integrate jev natively, so they don't.
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

  # OpenCode-flavored look; Ctrl+T hides full thinking
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
    # nono sandbox + sandboxed opencode launcher
    nono
    opencodeNono
    jevCli
  ];

  # goose/omp discover ~/.agents/skills; omp also scans its .omp/agent roots (linked below)
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
