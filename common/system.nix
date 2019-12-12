{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    curl
    networkmanager
    neovim
  ];

  fonts.fonts = with pkgs; [
    hasklig
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
}
