{
  pkgs,
  inputs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  programs.opencode.enable = true;
  programs.opencode.package = inputs.llm-agents.packages.${system}.opencode2;

  programs.claude-code.enable = true;
  programs.claude-code.package = inputs.llm-agents.packages.${system}.claude-code;
}
