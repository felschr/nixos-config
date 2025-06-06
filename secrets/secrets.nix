let
  # age-specific key in ~/.ssh/id_ed25519: `ssh-keygen -t ed25519`
  felschr = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGbQpMo1JOGk59Rzl6pVoOcMHOoqezph+aIlEXZP4rBu";
  users = [ felschr ];

  # `ssh-keygen -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key`
  home-pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFTQvIcSdhEKl/Kq+pcS/cPCyyZ1ygj+djfuaXzaRMx";
  home-server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILO+OLPr8zdOMYyKtm98AFJai7zbaxw7JhVWgOwu7K3C";
  cmdframe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAMcPrg69IqmH3V+7lgoXif/J6z4/aEi7w7p5jRn/lkp";
  systems = [
    home-pc
    home-server
    cmdframe
  ];
in
{
  "wireguard/seven/home-pc.key.age".publicKeys = [
    felschr
    home-pc
  ];
  "wireguard/seven/cmdframe.key.age".publicKeys = [
    felschr
    cmdframe
  ];
  "restic/b2.age".publicKeys = [
    felschr
    home-pc
    home-server
    cmdframe
  ];
  "restic/password.age".publicKeys = [
    felschr
    home-pc
    home-server
    cmdframe
  ];
  "smtp.age".publicKeys = [
    felschr
    home-pc
    home-server
  ];
  "samba.age".publicKeys = [
    felschr
    home-pc
    home-server
  ];
  "cloudflare.age".publicKeys = [
    felschr
    home-pc
    home-server
  ];
  "etebase-server.age".publicKeys = [
    felschr
    home-pc
    home-server
  ];
  "calibre-web/htpasswd.age".publicKeys = [
    felschr
    home-pc
    home-server
  ];
  "miniflux/admin.age".publicKeys = [
    felschr
    home-pc
    home-server
  ];
  "miniflux/oidc.age".publicKeys = [
    felschr
    home-pc
    home-server
  ];
  "paperless.age".publicKeys = [
    felschr
    home-pc
    home-server
  ];
  "nextcloud/admin.age".publicKeys = [
    felschr
    home-pc
    home-server
  ];

  "firefox/site-data-exceptions.toml.age".publicKeys = [
    felschr
    home-pc
    cmdframe
  ];

  # home-server
  "home-server/hostKey.age".publicKeys = [
    felschr
    home-server
  ];
  "lldap/key-seed.age".publicKeys = [
    felschr
    home-server
  ];
  "lldap/jwt.age".publicKeys = [
    felschr
    home-server
  ];
  "lldap/password.age".publicKeys = [
    felschr
    home-server
  ];
  "authelia/jwt.age".publicKeys = [
    felschr
    home-server
  ];
  "authelia/session.age".publicKeys = [
    felschr
    home-server
  ];
  "authelia/storage.age".publicKeys = [
    felschr
    home-server
  ];
  "authelia/oidc-hmac.age".publicKeys = [
    felschr
    home-server
  ];
  "authelia/oidc-issuer.age".publicKeys = [
    felschr
    home-server
  ];
  "forgejo/admin-password.age".publicKeys = [
    felschr
    home-server
  ];
  "hass/secrets.age".publicKeys = [
    felschr
    home-server
  ];
  "esphome/password.age".publicKeys = [
    felschr
    home-server
  ];
  "dendrite/env.age".publicKeys = [
    felschr
    home-server
  ];
  "dendrite/privateKey.age".publicKeys = [
    felschr
    home-server
  ];
}
