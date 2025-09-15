{ self, ... }:

{
  flake.lib.createUserModule =
    name:
    {
      homeModule,
      user ? { },
      usesContainers ? false,
      ...
    }:
    {
      inputs,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      users.users."${name}" = {
        isNormalUser = true;
        shell = pkgs.zsh;

        # increase sub{u,g}id range for container user namespaces
        subUidRanges = lib.optionals usesContainers [
          {
            startUid = 100000;
            count = 60000000;
          }
        ];
        subGidRanges = lib.optionals usesContainers [
          {
            startGid = 100000;
            count = 60000000;
          }
        ];
      }
      // user;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users."${name}" = {
          imports = [
            self.homeModules.git
            homeModule
          ];
        };
        extraSpecialArgs = { inherit inputs; };
      };
    };
}
