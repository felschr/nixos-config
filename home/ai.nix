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

  home.packages = [
    inputs.llm-agents.packages.${system}.agentsview
    inputs.llm-agents.packages.${system}.ck
  ];

  # goose & omp both discover Agent Skills (SKILL.md) from ~/.agents/skills,
  # the user-global location of the Agent Skills spec, by default.
  home.file = lib.mapAttrs' (
    name: src:
    lib.nameValuePair ".agents/skills/${name}" {
      source = src;
    }
  ) skills;
}
