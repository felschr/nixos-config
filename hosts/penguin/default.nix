{ self, ... }:
{
  perSystem =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    {
      packages.penguin = self.lib.mkOpenwrtImage {
        inherit pkgs;
        hostname = "penguin";
        timezone = "Europe/Berlin";
        ipaddr = "192.168.0.1";
        packages = [ "ds-lite" ];
      };
    };
}
