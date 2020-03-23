{ config, pkgs, ... }:

{
  imports = [
    ./i18n.nix
    ./nix.nix
  ];

  environment.systemPackages = with pkgs; [
    wget
    curl
    networkmanager
    neovim
  ];

  fonts.fonts = with pkgs; [
    fira-code
    noto-fonts
    noto-fonts-extra
    noto-fonts-cjk
    noto-fonts-emoji
  ];
  fonts.fontconfig.localConf = ''
    <fontconfig>
      <alias binding="weak">
        <family>sans-serif</family>
        <prefer>
          <family>emoji</family>
        </prefer>
      </alias>
      <alias binding="weak">
        <family>serif</family>
        <prefer>
          <family>emoji</family>
        </prefer>
      </alias>
    </fontconfig>
  '';

  services.printing.enable = true;
  services.fwupd.enable = true;
}
