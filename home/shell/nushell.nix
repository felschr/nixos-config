{
  lib,
  pkgs,
  ...
}:

let
  shellAliases = import ./aliases.nix;
  # z/zi expand to zoxide's cd/cdi, which only exist after zoxide's init is
  # sourced at the end of config.nu — nu aliases bind at parse time, so these
  # must be appended last (mkAfter) while the shell-side aliases expand lazily.
  zoxideAliases = [
    "z"
    "zi"
  ];
  aliasesStr = builtins.concatStringsSep "\n" (
    pkgs.lib.mapAttrsToList (k: v: "alias ${k} = ${v}") (
      builtins.removeAttrs shellAliases zoxideAliases
    )
  );
in
{
  programs.nushell = {
    enable = true;
    package = pkgs.unstable.nushell;
    configFile.text = ''
      $env.config = {
        edit_mode: "vi"
        show_banner: false
      }

      ${aliasesStr}

      use ${pkgs.unstable.nu_scripts}/share/nu_scripts/modules/network/ssh.nu *
      use ${pkgs.unstable.nu_scripts}/share/nu_scripts/modules/git/git.nu *
      use ${pkgs.unstable.nu_scripts}/share/nu_scripts/modules/nix/nix.nu *
      use ${pkgs.unstable.nu_scripts}/share/nu_scripts/modules/docker *
      use ${pkgs.unstable.nu_scripts}/share/nu_scripts/custom-completions/git/git-completions.nu *
      use ${pkgs.unstable.nu_scripts}/share/nu_scripts/custom-completions/nix/nix-completions.nu *
      use ${pkgs.unstable.nu_scripts}/share/nu_scripts/custom-completions/cargo/cargo-completions.nu *
      use ${pkgs.unstable.nu_scripts}/share/nu_scripts/custom-completions/npm/npm-completions.nu *
      use ${pkgs.unstable.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/wget.nu *
      # use ${pkgs.unstable.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/tar.nu * # TODO broken
      use ${pkgs.unstable.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/zstd.nu *
      use ${pkgs.unstable.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/unzstd.nu *
      use ${pkgs.unstable.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/npm.nu *
      use ${pkgs.unstable.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/dotnet.nu *
      use ${pkgs.unstable.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/terraform.nu *
    '';
    envFile.text = "";
    extraConfig = lib.mkAfter ''
      alias z = cd
      alias zi = cdi
    '';
  };
}
