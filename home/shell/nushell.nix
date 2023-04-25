{ config, pkgs, ... }:

let
  shellAliases = import ./aliases.nix;
  aliasesStr = builtins.concatStringsSep "\n"
    (pkgs.lib.mapAttrsToList (k: v: "alias ${k} = ${v}") shellAliases);

  nu_scripts = pkgs.fetchFromGitHub {
    owner = "nushell";
    repo = "nu_scripts";
    rev = "e8cda90b52e567ef0d85742ab44fc1cfe09a9917";
    hash = "sha256-eGuROnSgjSWRve2krb+Nz/53Svi4lKrcDB4tdWAOG9M=";
  };
in {
  programs.nushell = {
    enable = true;
    package = pkgs.unstable.nushell;
    configFile.text = ''
      let-env config = {
        edit_mode: "vi"
        show_banner: false
      }

      ${aliasesStr}

      use ${nu_scripts}/ssh/ssh.nu *
      use ${nu_scripts}/git/git.nu *
      use ${nu_scripts}/docker/docker.nu *
      use ${nu_scripts}/custom-completions/git/git-completions.nu *
      use ${nu_scripts}/custom-completions/nix/nix-completions.nu *
      use ${nu_scripts}/custom-completions/cargo/cargo-completions.nu *
      use ${nu_scripts}/custom-completions/npm/npm-completions.nu *
      use ${nu_scripts}/custom-completions/auto-generate/completions/wget.nu *
      # use ${nu_scripts}/custom-completions/auto-generate/completions/tar.nu * # TODO broken
      use ${nu_scripts}/custom-completions/auto-generate/completions/zstd.nu *
      use ${nu_scripts}/custom-completions/auto-generate/completions/unzstd.nu *
      use ${nu_scripts}/custom-completions/auto-generate/completions/npm.nu *
      use ${nu_scripts}/custom-completions/auto-generate/completions/dotnet.nu *
      use ${nu_scripts}/custom-completions/auto-generate/completions/terraform.nu *
    '';
    envFile.text = "";
  };
}
