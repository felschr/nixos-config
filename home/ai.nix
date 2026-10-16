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
      rev = "d01253d9db28d75080e36da3c1c31ef89454731e";
      hash = "sha256-QJwKiWbFh2lLXDhpEvWq02aqhbneRgqi9DTdO+/4Js0=";
    };
    anthropic-skills = pkgs.fetchFromGitHub {
      owner = "anthropics";
      repo = "skills";
      rev = "34040c9c568585f6929bedeaad110ad08f079624";
      hash = "sha256-tI4bTTBfI1ylltklGyiyA7pLoKXEWtrT6lrmwrpLbCw=";
    };
    atvari-skills = pkgs.fetchFromGitHub {
      owner = "atvari-eu";
      repo = "skills";
      rev = "22ad459910d9cb62707d16822d0af5ae27765c7f";
      hash = "sha256-2/N9MOZTtv0ZGyq2eg9X40+zaDOIyDrQHddHeLIhDvY=";
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
      rev = "e3ba2aa6f1e6f0bc4d69eb09c9f0d0a93af56156";
      hash = "sha256-PES5XrSYx0VBXWVHEDRykGy0SAmJfV/luzy8Gfg0aAQ=";
    };
    web-quality-skills = pkgs.fetchFromGitHub {
      owner = "addyosmani";
      repo = "web-quality-skills";
      rev = "afa8da942115f2961fdbfa80807ea0b232ff6c00";
      hash = "sha256-RW+30OFUYxNO/SqPJ/bmwAn965GOoxjeuKBMFBtESHE=";
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
    terranix = "${skillSources.nix-skills}/skills/terranix";
  };
in
{
  imports = [
    ./modules/goose.nix
    ./modules/omp.nix
  ];

  programs.opencode.enable = true;
  programs.opencode.package = inputs.llm-agents.packages.${system}.opencode2;
  programs.opencode.skills = skills;

  programs.claude-code.enable = true;
  programs.claude-code.package = inputs.llm-agents.packages.${system}.claude-code;
  programs.claude-code.skills = skills;

  programs.goose.enable = true;
  programs.goose.package = inputs.llm-agents.packages.${system}.goose-cli;

  programs.omp.enable = true;
  programs.omp.package = inputs.llm-agents.packages.${system}.omp;

  # Thinking blocks visible by default; Ctrl+T hides the full thinking inline.
  programs.omp.settings = {
    hideThinkingBlock = false;
    statusLine.compactThinkingLevel = false;
  };

  home.packages = [
    inputs.llm-agents.packages.${system}.agentsview
    inputs.llm-agents.packages.${system}.ck
  ];

  # goose & omp both discover Agent Skills (SKILL.md) from ~/.agents/skills,
  # the user-global location of the Agent Skills spec, by default.
  # omp also scans ~/.omp/agent/skills as its user-level skills root.
  home.file =
    lib.mapAttrs' (name: src: (lib.nameValuePair (".agents/skills/${name}") ({ source = src; }))) skills
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
