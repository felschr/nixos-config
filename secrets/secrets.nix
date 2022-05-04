let
  # age-specific key in ~/.ssh/id_ed25519: `ssh-keygen -t ed25519`
  felschr =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGbQpMo1JOGk59Rzl6pVoOcMHOoqezph+aIlEXZP4rBu";
  users = [ felschr ];

  # `ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key`
  home-pc =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFTQvIcSdhEKl/Kq+pcS/cPCyyZ1ygj+djfuaXzaRMx";
  home-server =
    # TODO which key is correct?
    # ssh-keyscan:
    # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFw/BoHY5LGtQblqwZA65/awp30lB/OQABd9dD7wc18n";
    # /etc/ssh/ssh_host_ed25519_key.pub:
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFTQvIcSdhEKl/Kq+pcS/cPCyyZ1ygj+djfuaXzaRMx";
  systems = [ home-pc home-server ];
in {
  "restic/b2.age".publicKeys = [ felschr home-pc home-server ];
  "restic/password.age".publicKeys = [ felschr home-pc home-server ];
  "smtp.age".publicKeys = [ felschr home-pc home-server ];
  "samba.age".publicKeys = [ felschr home-pc home-server ];
  "mqtt/felix.age".publicKeys = [ felschr home-pc home-server ];
  "mqtt/birgit.age".publicKeys = [ felschr home-pc home-server ];
  "mqtt/hass.age".publicKeys = [ felschr home-pc home-server ];
  "mqtt/tasmota.age".publicKeys = [ felschr home-pc home-server ];
  "mqtt/owntracks.age".publicKeys = [ felschr home-pc home-server ];
  "mqtt/owntracks-plain.age".publicKeys = [ felschr home-pc home-server ];
  "cfdyndns.age".publicKeys = [ felschr home-pc home-server ];
  "owntracks/htpasswd.age".publicKeys = [ felschr home-pc home-server ];
  "etebase-server.age".publicKeys = [ felschr home-pc home-server ];
  "miniflux.age".publicKeys = [ felschr home-pc home-server ];
  "paperless.age".publicKeys = [ felschr home-pc home-server ];
  "nextcloud/admin.age".publicKeys = [ felschr home-pc home-server ];

  "home-server/hostKey.age".publicKeys = [ felschr home-server ];
}
