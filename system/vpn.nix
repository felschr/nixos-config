{ config, pkgs, ... }:

{
  age.secrets.mullvad.file = ../secrets/mullvad.age;

  networking.wireguard.enable = true;

  services.tailscale.enable = true;
  services.mullvad-vpn.enable = true;

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # set some options after every daemon start
  # to avoid accidentally leaving unsafe settings
  systemd.services."mullvad-daemon" = {
    serviceConfig.LoadCredential =
      [ "account:${config.age.secrets.mullvad.path}" ];
    postStart = ''
      while ! ${pkgs.mullvad}/bin/mullvad status >/dev/null; do sleep 1; done

      ${pkgs.mullvad}/bin/mullvad lockdown-mode set on
      ${pkgs.mullvad}/bin/mullvad auto-connect set on
      ${pkgs.mullvad}/bin/mullvad dns set default
      ${pkgs.mullvad}/bin/mullvad lan set allow
      ${pkgs.mullvad}/bin/mullvad tunnel set ipv6 on
      ${pkgs.mullvad}/bin/mullvad tunnel set wireguard --quantum-resistant=on
      ${pkgs.mullvad}/bin/mullvad relay set tunnel-protocol wireguard
      ${pkgs.mullvad}/bin/mullvad relay set location de ber

      account="$(<"$CREDENTIALS_DIRECTORY/account")"
      current_account="$(${pkgs.mullvad}/bin/mullvad account get | grep "account:" | sed 's/.* //')"
      if [[ "$current_account" != "$account" ]]; then
        ${pkgs.mullvad}/bin/mullvad account login "$account"
      fi
    '';
  };
}
