{ config, pkgs, ... }:

{
  age.secrets.mullvad.file = ../secrets/mullvad.age;

  networking.wireguard.enable = true;

  services.mullvad-vpn.enable = true;

  # set some options after every daemon start
  # to avoid accidentally leaving unsafe settings
  systemd.services."mullvad-daemon" = {
    serviceConfig.LoadCredential =
      [ "account:${config.age.secrets.mullvad.path}" ];
    postStart = ''
      while ! ${pkgs.mullvad}/bin/mullvad status >/dev/null; do sleep 1; done

      ${pkgs.mullvad}/bin/mullvad always-require-vpn set on
      ${pkgs.mullvad}/bin/mullvad auto-connect set on
      ${pkgs.mullvad}/bin/mullvad dns set default \
        --block-ads --block-trackers --block-malware
      ${pkgs.mullvad}/bin/mullvad lan set allow
      ${pkgs.mullvad}/bin/mullvad tunnel ipv6 set on
      ${pkgs.mullvad}/bin/mullvad relay set tunnel-protocol wireguard
      ${pkgs.mullvad}/bin/mullvad relay set location de dus

      account="$(<"$CREDENTIALS_DIRECTORY/account")"
      current_account="$(${pkgs.mullvad}/bin/mullvad account get | grep "account:" | sed 's/.* //')"
      if [[ "$current_account" != "$account" ]]; then
        ${pkgs.mullvad}/bin/mullvad account login "$account"
      fi
    '';
  };
}
