let
  # age-specific key in ~/.ssh/id_ed25519: `ssh-keygen -t ed25519`
  felschr =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGbQpMo1JOGk59Rzl6pVoOcMHOoqezph+aIlEXZP4rBu";
  users = [ felschr ];

  # `ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key`
  home-pc =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFTQvIcSdhEKl/Kq+pcS/cPCyyZ1ygj+djfuaXzaRMx";
  home-server =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILO+OLPr8zdOMYyKtm98AFJai7zbaxw7JhVWgOwu7K3C";
  pilot1 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEucfNzPbDRdDjTaLG3PzN4lAzDAq3QUkaLvaRjjsCY";
  systems = [ home-pc home-server pilot1 ];
in {
  "mullvad.age".publicKeys = [ felschr home-pc home-server pilot1 ];
  "restic/b2.age".publicKeys = [ felschr home-pc home-server pilot1 ];
  "restic/password.age".publicKeys = [ felschr home-pc home-server pilot1 ];
  "smtp.age".publicKeys = [ felschr home-pc home-server ];
  "samba.age".publicKeys = [ felschr home-pc home-server ];
  "cloudflare.age".publicKeys = [ felschr home-pc home-server ];
  "etebase-server.age".publicKeys = [ felschr home-pc home-server ];
  "calibre-web/htpasswd.age".publicKeys = [ felschr home-pc home-server ];
  "miniflux.age".publicKeys = [ felschr home-pc home-server ];
  "paperless.age".publicKeys = [ felschr home-pc home-server ];
  "nextcloud/admin.age".publicKeys = [ felschr home-pc home-server ];
  "immich/.env.age".publicKeys = [ felschr home-pc home-server ];
  "immich/db-password.age".publicKeys = [ felschr home-pc home-server ];
  "immich/typesense/.env.age".publicKeys = [ felschr home-pc home-server ];

  # home-server
  "home-server/hostKey.age".publicKeys = [ felschr home-server ];
  "hass/secrets.age".publicKeys = [ felschr home-server ];
  "esphome/password.age".publicKeys = [ felschr home-server ];
  "focalboard/.env.age".publicKeys = [ felschr home-server ];
  "focalboard/db-password.age".publicKeys = [ felschr home-server ];
  "dendrite/.env.age".publicKeys = [ felschr home-server ];
  "dendrite/privateKey.age".publicKeys = [ felschr home-server ];
}
