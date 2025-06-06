{ lib }:
let
  inherit (lib)
    filterAttrs
    concatStrings
    concatStringsSep
    mapAttrsToList
    concatLists
    foldlAttrs
    boolToString
    ;
  inherit (builtins) typeOf toString stringLength;

  # list -> array
  array = a: "[${concatStringsSep "," (map serialise a)}]";

  # attrset -> hashmap
  _assoc = a: mapAttrsToList (name: val: "${name}: ${val},") a;
  assoc = a: ''
    {
        ${concatStringsSep "\n    " (concatLists (map _assoc a))}
    }
  '';

  stringArray = a: array (map toQuotedString a);

  tuple = a: "(${concatStringsSep "," (map serialise a)})";
  enum =
    s:
    if isNull s.value then
      s.name
    else
      concatStrings [
        s.name
        "("
        (serialise s.value)
        ")"
      ];

  option =
    value:
    if isNull value then
      "None"
    else
      enum {
        name = "Some";
        inherit value;
      };

  # attrset -> struct
  _struct_kv =
    k: v:
    if v == null then
      ""
    else
      (concatStringsSep ": " [
        k
        (serialise v)
      ]);
  _struct_concat =
    s:
    foldlAttrs (
      acc: k: v:
      if stringLength acc > 0 then
        concatStringsSep ", " [
          acc
          (_struct_kv k v)
        ]
      else
        _struct_kv k v
    ) "" s;
  _struct_filt = s: _struct_concat (filterAttrs (k: v: v != null) s);
  struct = s: "(${_struct_filt s})";

  toQuotedString = s: ''"${toString s}"'';

  # this is an enum, but use string interp to make sure it's put in the nix store
  path = p: ''Path("${p}")'';

  # attrset for best-effort serialisation of nix types
  # currently, no way to differentiate between enums and structs
  serialisers = {
    int = toString;
    float = toString;
    bool = boolToString;
    # can't assume quoted string, sometimes it's a Rust enum
    string = toString;
    path = path;
    null = _: "None";
    set = struct;
    list = array;
  };

  serialise = v: serialisers.${typeOf v} v;

in
{
  inherit
    array
    assoc
    tuple
    stringArray
    serialise
    option
    path
    struct
    toQuotedString
    enum
    ;

  # some handy wrapper types, to reduce transformation effort in modules producing Ron
  types = {
    # string type, but implicitly wraps in quote marks for usage in Ron
    str = (lib.types.coercedTo lib.types.str toQuotedString lib.types.str) // {
      description = "string";
    };

    # takes a (non submodule) type, and implicitly wraps in Rust Option<> type
    option =
      type:
      let
        wantedType = lib.types.nullOr (type);
      in
      (lib.types.coercedTo (wantedType) (option) lib.types.str)
      // {
        description = wantedType.description;
      };
  };
}
