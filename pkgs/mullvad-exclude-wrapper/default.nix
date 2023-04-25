{ writeShellScript, genericBinWrapper, mullvad-vpn }:
args:
let
  wrapper = writeShellScript "mullvad-exclude" ''
    ${mullvad-vpn}/bin/mullvad-exclude "@EXECUTABLE@" "$@"
  '';
in genericBinWrapper (args // { inherit wrapper; })
