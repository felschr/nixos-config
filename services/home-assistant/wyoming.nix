{ inputs, ... }:

{
  # TODO they don't exist, so not disabling them
  /* disabledModules = [
       "services/audio/wyoming/piper.nix"
       "services/audio/wyoming/faster-whisper.nix"
     ];
  */

  # TODO fails with infinite recursion, why?
  # TODO perhaps because of the `pkgs.unstable` override?
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/audio/wyoming/piper.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/audio/wyoming/faster-whisper.nix"

  ];

  /* services.wyoming.piper.servers = {
       "en" = {
         enable = true;
         voice = "en_GB-alba-medium";
         uri = "tcp://0.0.0.0:10200";
         speaker = 0;
       };
     };

     services.wyoming.faster-whisper.servers = {
       "tiny-en" = {
         enable = true;
         model = "tiny-int8";
         language = "en";
         uri = "tcp://0.0.0.0:10300";
         device = "cpu";
       };
     };
  */
}
