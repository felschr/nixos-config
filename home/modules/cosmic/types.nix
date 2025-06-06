{ lib, ron }:

let
  inherit (lib) types;
in
lib.fix (self: {
  theme = types.enum [
    "Dark"
    "Light"
    "System"
  ];
  density = types.enum [
    "Compact"
    "Spacious"
    "Standard"
  ];
  weight = types.enum [
    "Thin"
    "ExtraLight"
    "Light"
    "Normal"
    "Medium"
    "Semibold"
    "Bold"
    "ExtraBold"
    "Black"
  ];
  stretch = types.enum [
    "UltraCondensed"
    "ExtraCondensed"
    "Condensed"
    "SemiCondensed"
    "Normal"
    "SemiExpanded"
    "Expanded"
    "ExtraExpanded"
    "UltraExpanded"
  ];
  style = types.enum [
    "Normal"
    "Italic"
    "Oblique"
  ];

  # libcosmic
  font_config = types.submodule {
    options = {
      family = lib.mkOption {
        type = ron.types.str;
        default = null;
      };
      weight = lib.mkOption {
        type = types.nullOr self.weight;
        default = null;
      };
      stretch = lib.mkOption {
        type = types.nullOr self.stretch;
        default = null;
      };
      style = lib.mkOption {
        type = types.nullOr self.style;
        default = null;
      };
    };
  };

  # Files
  files_desktop = types.submodule {
    options = {
      grid_spacing = lib.mkOption {
        type = types.nullOr types.int;
        default = null;
      };
      icon_size = lib.mkOption {
        type = types.nullOr types.int;
        default = null;
      };
      show_content = lib.mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
      show_mounted_drives = lib.mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
      show_trash = lib.mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
    };
  };
  files_favorites = types.listOf (
    types.oneOf [
      (types.enum [
        "Home"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Videos"
      ])
      (lib.types.strMatching ''^Path\(".*"\)$'')
    ]
  );
  files_view = types.enum [
    "Grid"
    "List"
  ];
  files_icon_sizes = types.submodule {
    options = {
      list = lib.mkOption {
        type = types.nullOr types.int;
        default = null;
      };
      grid = lib.mkOption {
        type = types.nullOr types.int;
        default = null;
      };
    };
  };
  files_tab_config = types.submodule {
    options = {
      view = lib.mkOption {
        type = types.nullOr self.files_view;
        default = null;
      };
      folders_first = lib.mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
      show_hidden = lib.mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
      icon_sizes = lib.mkOption {
        type = types.nullOr self.files_icon_sizes;
        default = null;
      };
      single_click = lib.mkOption {
        type = types.nullOr types.bool;
        default = null;
      };
    };
  };
})
