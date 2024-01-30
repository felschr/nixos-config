{ self, inputs, ... }: {
  perSystem = { self', pkgs, lib, ... }: {
    packages.doctr = self.lib.mkOpenwrtImage {
      inherit pkgs;
      hostname = "doctr";
      timezone = "Europe/Berlin";
      ipaddr = "192.168.1.1";
    };
  };
}
