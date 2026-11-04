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
      rev = "5868f7c05020e047c00e68e4abf9253cce864f41";
      hash = "sha256-/YPVYdRNhOkW09WF63xhSwELNzv/D1cOvQep5taIlVQ=";
    };
    anthropic-skills = pkgs.fetchFromGitHub {
      owner = "anthropics";
      repo = "skills";
      rev = "ca45fc496a3436251f191354091d557da31c15b5";
      hash = "sha256-MkCOANBAqCc1WmNf7S8PsyAphGJAIzEXGyCm8RrCR9M=";
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
      rev = "96608e078b2d5ea607c5c3b8b5a54d1c1fba6846";
      hash = "sha256-PhPtZbeX2wBp19GtWRy+fV93+fFYZe5S487eXPDl/us=";
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
      rev = "302eea662c54bca6730873fe245bec1d69ebc23d";
      hash = "sha256-aQ7HheEFLarcil4jYIKn/FUIVOnw1JCoh0dYXZHTJ0E=";
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

  # opencode (plugin) and omp (TypeSafeJudge) integrate jev natively, so only
  # claude and goose load the skills
  jevSkills = [
    "system-one"
    "auto-system-one"
  ];

  # Shared ~ root (goose & omp), without the jev skills
  agentSkills = builtins.removeAttrs skills jevSkills;

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

  llmAgents = inputs.llm-agents.packages.${system};
  # nono — agent sandbox; version tracks the llm-agents pin
  nono = llmAgents.nono;

  # mkNono <outName> <profile> <exe> <extra> <herdrHint> [pty]: run <exe> (a
  # store path from the llm-agents pin — pinned by this flake, not the host
  # PATH) under the nolabs-ai/<profile> pack profile, cwd granted; leading
  # --nono-* arguments pass through to nono. herdrHint: the kind herdr
  # screen-detects such a pane as, or null if herdr has no manifest for it.
  # Every wrapper grants /dev/ptmx (--allow-file): in-agent terminals and
  # interactive shell commands allocate ptys, and nono grants /dev/pts by
  # default but never the multiplexer device (openpty() fails EPERM without it).
  #
  # The hint rides on a dumpable carrier shell rather than a plain
  # `exec nono run`: herdr reads HERDR_AGENT from /proc/<pid>/environ of the
  # pane's foreground process; a self-export never shows up there and nono is
  # non-dumpable. https://herdr.dev/docs/agents/#vms-and-sandbox-wrappers
  # https://github.com/herdrdev/herdr/discussions/514
  mkNono =
    outName: agent: exe: extra: herdrHint:
    pkgs.writeShellScriptBin outName ''
      # --allow-unix-socket: standing grant for herdr's lifecycle integrations
      # (the connection target may not exist yet; connect() fails gracefully
      # until the herdr server runs). Harmless for agents without hooks.
      nono_flags="--allow-cwd --allow-unix-socket $HOME/.config/herdr/herdr.sock --allow-file /dev/ptmx"
      while [ "$#" -gt 0 ]; do
        case "$1" in
          --nono-*) nono_flags="''${nono_flags} --''${1#--nono-}"; shift ;;
          *) break ;;
        esac
      done
      # git cannot reach the signing key inside the sandbox (~/.ssh is hidden),
      # so a signed commit fails closed. Default commits and tags to unsigned;
      # these act like `git -c`, so an explicit `git commit -S` still signs.
      export GIT_CONFIG_COUNT=2
      export GIT_CONFIG_KEY_0=commit.gpgsign GIT_CONFIG_VALUE_0=false
      export GIT_CONFIG_KEY_1=tag.gpgsign GIT_CONFIG_VALUE_1=false
      ${
        lib.optionalString (herdrHint != null) "HERDR_AGENT=${herdrHint} "
      }NONO_FLAGS="$nono_flags" exec ${pkgs.runtimeShell} -c '
        exec ${nono}/bin/nono run $NONO_FLAGS --profile nolabs-ai/${agent} ${
          lib.concatStringsSep " " (
            [
              "--"
              exe
            ]
            ++ extra
          )
        } "$@"
      ' herdr-${agent} "$@"
    '';

  # defaults: the plain agent commands resolve to the nono sandbox wrappers
  # (`opencode` never existed on PATH before — llm-agents installs `opencode2`)
  opencode = mkNono "opencode" "opencode" "${llmAgents.opencode2}/bin/opencode2" [
    "--standalone"
  ] "opencode";
  claude = mkNono "claude" "claude" "${llmAgents.claude-code}/bin/claude" [ ] "claude";
  goose = mkNono "goose" "goose" "${llmAgents.goose-cli}/bin/goose" [ ] null;
  omp = mkNono "omp" "omp" "${llmAgents.omp}/bin/omp" [ ] "omp";

  # nolabs-ai nono pack repo (pack-relative plugin/skill assets; profiles stay
  # registry-managed via `nono pull`). After `nono update <pack>`, bump this
  # pin to the matching release tag.
  nonoPacks = pkgs.fetchFromGitHub {
    owner = "nolabs-ai";
    repo = "nono-packs";
    rev = "a4432e55c02cfdea56ada32ddc7a5adf23e7e0d2";
    hash = "sha256-kS2701quGR4KmUJh4VUTThjo0A7MWx5zxyv7YRPE0WI=";
  };

  # eval-time guard against pack layout drift: every linked pack asset must exist
  packLink =
    target: rel:
    assert builtins.pathExists "${nonoPacks}/${rel}";
    lib.nameValuePair target { source = "${nonoPacks}/${rel}"; };

  # Personal global rules, tracked once and linked to each agent's user-level
  # rules path. Project-level AGENTS.md/CLAUDE.md still wins where present.
  globalInstructions = ./ai/AGENTS.md;
  globalInstructionPaths = [
    ".agents/AGENTS.md" # generic agent dir, picked up by omp's .agent/.agents scan
    ".config/opencode/AGENTS.md" # opencode; omp reads it via its compat provider
    ".claude/CLAUDE.md" # claude code (opencode's fallback source)
    ".config/goose/.goosehints" # goose
  ];
in
{
  imports = [
    ./modules/goose.nix
    ./modules/omp.nix
  ];

  programs.opencode.enable = true;
  programs.opencode.package = opencode;
  # settings replaces ~/.config/opencode/opencode.json wholesale; update the plugin by bumping its pin
  programs.opencode.settings = {
    # the binary is Nix-managed; a self-updater would fight the store path
    update = "disable";
    lsp = true;
    # Nix-linked skills never change, and watching them fails with
    # "watcher backend not supported"
    watcher.ignore = [ "**/.config/opencode/skills/**" ];
    # primary agents rest on the Auto entry, so jev routes each turn
    agents = {
      build.model = "opencode-decisions/auto";
      plan.model = "opencode-decisions/auto";
    };
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
        enabled = false;
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
        # needs an interactive login; fails on every session start until then
        enabled = false;
        type = "remote";
        url = "https://api.munito.ai/mcp/v1";
      };
    };
    plugins = [
      {
        package = "github:atvari-eu/opencode-decisions#3cfec664ff44c625f3f825796fca11b5584966d7";
        options = {
          provider = "opencode";
          model = "jev-1.13";
          screen = {
            enabled = true;
            mode = "redact";
            tools = [
              "webfetch"
              "websearch"
              "mcp/*"
            ];
          };
          scrub.enabled = true;
          tools = true;
          commands = true;
          cache = true;
          # review turns route on the review question, never onto Auto's models
          agents.review = {
            criteria = "@review";
            effort.min = "medium";
          };
          doneCheck.auto = true; # completion probe when the session goes idle
          compaction = {
            enabled = true;
            mode = "replace";
            # compact at idle: jev passes are ~free, big prompts are not
            auto.tokens = 60000;
          };
          approvals = {
            # operator-asserted sandbox posture for jev calibration; must be true
            sandbox = "nono (landlock); workspace, /tmp and opencode/npm/claude state dirs writable; all outbound network allowed; runs unprivileged";
            # heuristic approval gates before any jev calls
            gates = {
              secrets = true;
              readonlyBypass = true;
            };
            minConfidence = {
              approve = 0.5;
              refuse = 0.7;
            };
            onGate = "deny";
            onApprove = "allow";
            onRefuse = "deny";
            onNoVerdict = "allow";
            onFail = "ask";
            # the permissions object opts jev-assisted approvals in with plugin
            # defaults (full delegation; bars until /jev-approval-stats calibration);
            # `ask` entries pin must-prompt slices
            permissions = [
              # always allow
              (perm "external_directory" "*" "allow") # safe in nono sandbox
              (perm "shell" "nono why *" "allow")
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
              (perm "shell" "nix shell *" "allow")
              # always ask
              (perm "shell" "nixos-rebuild *" "ask")
              (perm "shell" "git push *" "ask")
            ];
          };
        };
      }
    ];
    permissions = [
      (perm "*" "*" "ask")
    ];
  };

  # The built-in `/review` in a fresh context. No `$ARGUMENTS` on purpose:
  # without the placeholder the argument is appended as a paragraph, which also
  # reads fine when none is given.
  programs.opencode.commands.review-cold = ''
    ---
    description: review changes [commit|branch|pr] in an isolated subagent, defaults to uncommitted
    agent: review
    subagent: true
    ---
    Review the change indicated below, if any.
  '';

  # Read-only apart from git inspection; questions would stall the caller. The
  # description is what the model picks a subagent by, so it carries the when.
  programs.opencode.agents.review = ''
    ---
    description: Cold read of a change - reports findings, never edits. Use before commit or push, especially for a change the caller wrote.
    mode: subagent
    model: opencode-decisions/auto-review
    permissions:
      - action: "*"
        resource: "*"
        effect: deny
      - action: read
        resource: "*"
        effect: allow
      - action: glob
        resource: "*"
        effect: allow
      - action: grep
        resource: "*"
        effect: allow
      - action: shell
        resource: "git diff*"
        effect: allow
      - action: shell
        resource: "git show*"
        effect: allow
      - action: shell
        resource: "git log*"
        effect: allow
      - action: shell
        resource: "git merge-base*"
        effect: allow
      - action: shell
        resource: "git status*"
        effect: allow
      - action: shell
        resource: "git rev-parse*"
        effect: allow
      - action: shell
        resource: "rg *"
        effect: allow
    ---
    You review a change and report defects in it. You do not edit, you do not
    plan the implementation, and you do not ask questions - the caller cannot
    answer them from here.

    Determine the scope yourself. With no other information, review the
    uncommitted working copy: tracked modifications plus untracked files. If the
    caller names a commit, branch or PR, use that - commit means the last
    commit, branch means this branch against its merge base with its upstream,
    else origin/main, pr means the pull request for this branch. Collect the
    diff yourself with git and read the files it touches. Do not ask the caller
    for the diff, and do not ask why the change was made.

    Read the change as if you had never seen the work and had no stake in it. If
    a claim in a comment, commit message or test name does not match the code,
    that mismatch is itself a finding.

    For every finding give:
    - path:line, the narrowest range that shows it
    - severity: blocking (wrong behaviour, data loss, security), should-fix
      (fragile, unclear, untested), or nit (style)
    - what breaks, and for whom
    - the fix, in one or two sentences

    If the change is correct, say so in one line and list what you checked -
    silence is not a verdict. End with either "safe to land" or "needs fixes"
    plus the blocking list.
  '';

  # claude/goose load the jev skills; opencode (plugin) & omp (TypeSafeJudge) integrate jev natively, so they don't.
  programs.opencode.skills = agentSkills // {
    nono-sandbox =
      assert builtins.pathExists "${nonoPacks}/opencode/skills/nono-sandbox";
      "${nonoPacks}/opencode/skills/nono-sandbox";
  };

  programs.claude-code.enable = true;
  programs.claude-code.package = claude;
  programs.claude-code.skills = skills;

  programs.goose.enable = true;
  programs.goose.package = goose;

  programs.omp.enable = true;
  programs.omp.package = omp;

  # OpenCode-flavored look; Ctrl+T hides full thinking
  programs.omp.settings = {
    hideThinkingBlock = false;
    statusLine.compactThinkingLevel = false;

    theme.dark = "anthracite";
    composer.shape = "box";
    statusLine.transparent = true;
    statusLine.separator = "slash";

    # Safety net: omp also scans ~/.agents/skills.
    skills.ignoredSkills = jevSkills;
  };

  # OpenCode installs every pinned plugin revision into its own npm tree under
  # ~/.cache/opencode/npm (`git-<repo>-<hash>/<timestamp>/node_modules`, ~300 MB
  # each) and never removes the old ones - bumping the pin below leaks one tree
  # per release. Keep the two newest (the pin in use plus its predecessor, so a
  # rollback does not refetch) and drop the rest on every switch.
  home.activation.pruneOpencodePluginCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cache="$HOME/.cache/opencode/npm"
    if [ -d "$cache" ]; then
      keep=2
      n=0
      # newest first (dir names are content hashes, so the glob order is not age)
      for dir in $(ls -1dt "$cache"/git-* 2>/dev/null); do
        [ -d "$dir" ] || continue
        n=$((n + 1))
        if [ "$n" -gt "$keep" ]; then
          verboseEcho "Pruning stale opencode plugin cache: $dir"
          run rm -rf "$dir"
        fi
      done
    fi
  '';

  home.packages = [
    inputs.llm-agents.packages.${system}.agentsview
    inputs.llm-agents.packages.${system}.ck
    inputs.llm-agents.packages.${system}.herdr
    inputs.llm-agents.packages.${system}.collie
    nono
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
    ) ompExtensionSkills
    // lib.listToAttrs [
      (packLink ".config/opencode/plugins/nono-sandbox.ts" "opencode/plugin/nono-sandbox.ts")
      (packLink ".agents/plugins/nono" "goose")
      (packLink ".omp/agent/extensions/nono-sandbox" "omp/extensions/nono-sandbox")
      (packLink ".omp/agent/skills/nono-sandbox" "omp/skills/nono-sandbox")
    ]
    // lib.genAttrs globalInstructionPaths (_: {
      source = globalInstructions;
    });
}
