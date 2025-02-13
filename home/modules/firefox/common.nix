{ lib, ... }:

let
  userPrefValue =
    pref:
    builtins.toJSON (
      if lib.isBool pref || lib.isInt pref || lib.isString pref then pref else builtins.toJSON pref
    );
in
{
  mkConfig =
    prefs:
    lib.concatStrings (
      lib.mapAttrsToList (name: value: ''
        user_pref("${name}", ${userPrefValue value});
      '') prefs
    );
}
