{ config, pkgs, ... }:

with pkgs;
let
  unstable = import <nixos-unstable> {
    config = removeAttrs config.nixpkgs.config [ "packageOverrides" ];
  };
  shellAliases = {
    chromium = "chromium --force-dark-mode";
    emacs = "emacsclient -c";
  };
  dotnet-sdk_3 = pkgs.callPackage (import (pkgs.fetchFromGitHub {
    name = "nixos-pr-dotnet-sdk_3";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "c3978355e1b1b23a0e1af5abe4a8901321126f49";
    sha256 = "006jxl07kfl2qbsglx0nsnmygdj3wvwfl98gpl3bprrja0l4gplk";
  } + /pkgs/development/compilers/dotnet/sdk/3.nix )) {};
in
{
  imports = [
    # ./vscode.nix
  ];
  
  home-manager.users.felschr = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowBroken = true; # needed for steam

    xdg.mimeApps.enable = true;
    xdg.mimeApps.defaultApplications = {
      "text/html" = [ "chromium-browser.desktop" ];
      "text/calendar" = [ "chromium-browser.desktop" ];
      "x-scheme-handler/mailto" = [ "chromium-browser.desktop" ];
    };

    # xsession.enable = true;
    # xsession.windowManager.xmonad.enable = true;
    # xsession.windowManager.command = "gnome-shell";

    dconf.enable = true;
    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = [
          "dash-to-panel@jderose9.github.com"
          "TopIcons@phocean.net"
        ];
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "chromium-browser.desktop"
          "code.desktop"
        ];
      };
      "org/gnome/shell/extensions/dash-to-panel" = {
        appicon-padding = 4;
        panel-size = 36;
      };
    };

    gtk.enable = true;
    gtk.theme.name = "Adwaita-dark";
    gtk.gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    services.redshift = {
      enable = true;
      latitude = "53.2603609";
      longitude = "10.4014691";
    };

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    programs.bash = {
      inherit shellAliases;
    };

    programs.fish = {
      enable = true;
      inherit shellAliases;
    };

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        vim-nix
      ];
    };

    programs.git = {
      enable = true;
      userName = "Felix Schroeter";
      userEmail = "fs@upsquared.com";
    };

    services.emacs.enable = true;
    programs.emacs.enable = true;

    services.keybase.enable = true;
    services.kbfs.enable = true;

    programs.chromium = {
      enable = true;
    };

    programs.firefox.enable = true;

    home.file.".envrc".text = ''
      dotenv
    '';

    home.sessionVariables = {
    };

    home.packages = with pkgs; [
      gparted

      # productivity
      signal-desktop
      discord
      keybase-gui
      libreoffice
      skypeforlinux
      vscode

      # development tools
      unzip
      # dotnet-sdk
      dotnet-sdk_3
      omnisharp-roslyn
      kubectl
      kubernetes-helm
      awscli
    ];

    home.stateVersion = "19.09";
  };
}
