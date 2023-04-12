{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.mullvad-browser;

  jsonFormat = pkgs.formats.json { };

  dataConfigPath = ".mullvad/mullvadbrowser";

  profilesPath = dataConfigPath;

  # The extensions path shared by all profiles; will not be supported
  # by future Firefox versions.
  extensionPath = "extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";

  profiles = flip mapAttrs' cfg.profiles (_: profile:
    nameValuePair "Profile${toString profile.id}" {
      Name = profile.name;
      Path = profile.path;
      IsRelative = 1;
      Default = if profile.isDefault then 1 else 0;
    }) // {
      General = { StartWithLastProfile = 1; };
    };

  profilesIni = generators.toINI { } profiles;

  userPrefValue = pref:
    builtins.toJSON (if isBool pref || isInt pref || isString pref then
      pref
    else
      builtins.toJSON pref);

  mkUserJs = prefs: extraPrefs: bookmarks:
    let
      prefs' = lib.optionalAttrs ([ ] != bookmarks) {
        "browser.bookmarks.file" = toString (firefoxBookmarksFile bookmarks);
        "browser.places.importBookmarksHTML" = true;
      } // prefs;
    in ''
      // Generated by Home Manager.

      ${concatStrings (mapAttrsToList (name: value: ''
        user_pref("${name}", ${userPrefValue value});
      '') prefs')}

      ${extraPrefs}
    '';

  mkProfileBin = profile:
    let
      name = "mullvad-browser-${profile}";
      scriptBin = pkgs.writeScriptBin name ''
        mullvad-browser -P "${profile}" --class="${name}" $@
      '';
      desktopFile = pkgs.makeDesktopItem {
        inherit name;
        exec = "${scriptBin}/bin/${name} %U";
        icon = "mullvad-browser";
        extraConfig.StartupWMClass = name;
        desktopName = "Mullvad Browser (${profile})";
        genericName = "Web Browser";
        categories = [ "Network" "WebBrowser" "Security" ];
      };
    in pkgs.runCommand name { } ''
      mkdir -p $out/{bin,share}
      cp -r ${scriptBin}/bin/${name} $out/bin/${name}
      cp -r ${desktopFile}/share/applications $out/share/applications
    '';

  firefoxBookmarksFile = bookmarks:
    let
      indent = level:
        lib.concatStringsSep "" (map (lib.const "  ") (lib.range 1 level));

      bookmarkToHTML = indentLevel: bookmark:
        ''
          ${indent indentLevel}<DT><A HREF="${
            escapeXML bookmark.url
          }" ADD_DATE="0" LAST_MODIFIED="0"${
            lib.optionalString (bookmark.keyword != null)
            " SHORTCUTURL=\"${escapeXML bookmark.keyword}\""
          }>${escapeXML bookmark.name}</A>'';

      directoryToHTML = indentLevel: directory: ''
        ${indent indentLevel}<DT>${
          if directory.toolbar then
            ''<H3 PERSONAL_TOOLBAR_FOLDER="true">Bookmarks Toolbar''
          else
            "<H3>${escapeXML directory.name}"
        }</H3>
        ${indent indentLevel}<DL><p>
        ${allItemsToHTML (indentLevel + 1) directory.bookmarks}
        ${indent indentLevel}</p></DL>'';

      itemToHTMLOrRecurse = indentLevel: item:
        if item ? "url" then
          bookmarkToHTML indentLevel item
        else
          directoryToHTML indentLevel item;

      allItemsToHTML = indentLevel: bookmarks:
        lib.concatStringsSep "\n"
        (map (itemToHTMLOrRecurse indentLevel) bookmarks);

      bookmarkEntries = allItemsToHTML 1 bookmarks;
    in pkgs.writeText "firefox-bookmarks.html" ''
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <!-- This is an automatically generated file.
        It will be read and overwritten.
        DO NOT EDIT! -->
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks Menu</H1>
      <DL><p>
      ${bookmarkEntries}
      </p></DL>
    '';

in {
  meta.maintainers = [ maintainers.rycee maintainers.kira-bruneau ];

  options = {
    programs.mullvad-browser = {
      enable = mkEnableOption "Mullvad Browser";

      createProfileBins = mkOption {
        type = types.bool;
        default = false;
        description = ''
          When enabled installs a binary for all non-default profiles named `mullvad-browser-''${profile}`.
          This also includes a `.desktop` file that is configured to show separate icons (on GNOME at least).
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.mullvad-browser;
        defaultText = literalExpression "pkgs.mullvad-browser";
        example = literalExpression ''
          pkgs.mullvad-browser.override {
            # See nixpkgs' mullvad-browser/default.nix to check which options you can use
            pulseaudioSupport = true;
          }
        '';
        description = "The Mullvad Browser package to use.";
      };

      profiles = mkOption {
        type = types.attrsOf (types.submodule ({ config, name, ... }: {
          options = {
            name = mkOption {
              type = types.str;
              default = name;
              description = "Profile name.";
            };

            id = mkOption {
              type = types.ints.unsigned;
              default = 0;
              description = ''
                Profile ID. This should be set to a unique number per profile.
              '';
            };

            settings = mkOption {
              type = types.attrsOf (jsonFormat.type // {
                description =
                  "Firefox preference (int, bool, string, and also attrs, list, float as a JSON string)";
              });
              default = { };
              example = literalExpression ''
                {
                  "browser.startup.homepage" = "https://nixos.org";
                  "browser.search.region" = "GB";
                  "browser.search.isUS" = false;
                  "distribution.searchplugins.defaultLocale" = "en-GB";
                  "general.useragent.locale" = "en-GB";
                  "browser.bookmarks.showMobileBookmarks" = true;
                  "browser.newtabpage.pinned" = [{
                    title = "NixOS";
                    url = "https://nixos.org";
                  }];
                }
              '';
              description = ''
                Attribute set of Firefox preferences.

                Firefox only supports int, bool, and string types for
                preferences, but home-manager will automatically
                convert all other JSON-compatible values into strings.
              '';
            };

            extraConfig = mkOption {
              type = types.lines;
              default = "";
              description = ''
                Extra preferences to add to <filename>user.js</filename>.
              '';
            };

            userChrome = mkOption {
              type = types.lines;
              default = "";
              description = "Custom Firefox user chrome CSS.";
              example = ''
                /* Hide tab bar in FF Quantum */
                @-moz-document url("chrome://browser/content/browser.xul") {
                  #TabsToolbar {
                    visibility: collapse !important;
                    margin-bottom: 21px !important;
                  }

                  #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
                    visibility: collapse !important;
                  }
                }
              '';
            };

            userContent = mkOption {
              type = types.lines;
              default = "";
              description = "Custom Firefox user content CSS.";
              example = ''
                /* Hide scrollbar in FF Quantum */
                *{scrollbar-width:none !important}
              '';
            };

            bookmarks = mkOption {
              type = let
                bookmarkSubmodule = types.submodule ({ config, name, ... }: {
                  options = {
                    name = mkOption {
                      type = types.str;
                      default = name;
                      description = "Bookmark name.";
                    };

                    keyword = mkOption {
                      type = types.nullOr types.str;
                      default = null;
                      description = "Bookmark search keyword.";
                    };

                    url = mkOption {
                      type = types.str;
                      description = "Bookmark url, use %s for search terms.";
                    };
                  };
                }) // {
                  description = "bookmark submodule";
                };

                bookmarkType = types.addCheck bookmarkSubmodule (x: x ? "url");

                directoryType = types.submodule ({ config, name, ... }: {
                  options = {
                    name = mkOption {
                      type = types.str;
                      default = name;
                      description = "Directory name.";
                    };

                    bookmarks = mkOption {
                      type = types.listOf nodeType;
                      default = [ ];
                      description = "Bookmarks within directory.";
                    };

                    toolbar = mkOption {
                      type = types.bool;
                      default = false;
                      description = "If directory should be shown in toolbar.";
                    };
                  };
                }) // {
                  description = "directory submodule";
                };

                nodeType = types.either bookmarkType directoryType;
              in with types;
              coercedTo (attrsOf nodeType) attrValues (listOf nodeType);
              default = [ ];
              example = literalExpression ''
                [
                  {
                    name = "wikipedia";
                    keyword = "wiki";
                    url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
                  }
                  {
                    name = "kernel.org";
                    url = "https://www.kernel.org";
                  }
                  {
                    name = "Nix sites";
                    bookmarks = [
                      {
                        name = "homepage";
                        url = "https://nixos.org/";
                      }
                      {
                        name = "wiki";
                        url = "https://nixos.wiki/";
                      }
                    ];
                  }
                ]
              '';
              description = ''
                Preloaded bookmarks. Note, this may silently overwrite any
                previously existing bookmarks!
              '';
            };

            path = mkOption {
              type = types.str;
              default = name;
              description = "Profile path.";
            };

            isDefault = mkOption {
              type = types.bool;
              default = config.id == 0;
              defaultText = "true if profile ID is 0";
              description = "Whether this is a default profile.";
            };

            search = {
              force = mkOption {
                type = with types; bool;
                default = false;
                description = ''
                  Whether to force replace the existing search
                  configuration. This is recommended since Firefox will
                  replace the symlink for the search configuration on every
                  launch, but note that you'll lose any existing
                  configuration by enabling this.
                '';
              };

              default = mkOption {
                type = with types; nullOr str;
                default = null;
                example = "DuckDuckGo";
                description = ''
                  The default search engine used in the address bar and search bar.
                '';
              };

              order = mkOption {
                type = with types; uniq (listOf str);
                default = [ ];
                example = [ "DuckDuckGo" "Google" ];
                description = ''
                  The order the search engines are listed in. Any engines
                  that aren't included in this list will be listed after
                  these in an unspecified order.
                '';
              };

              engines = mkOption {
                type = with types; attrsOf (attrsOf jsonFormat.type);
                default = { };
                example = literalExpression ''
                  {
                    "Nix Packages" = {
                      urls = [{
                        template = "https://search.nixos.org/packages";
                        params = [
                          { name = "type"; value = "packages"; }
                          { name = "query"; value = "{searchTerms}"; }
                        ];
                      }];

                      icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                      definedAliases = [ "@np" ];
                    };

                    "NixOS Wiki" = {
                      urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
                      iconUpdateURL = "https://nixos.wiki/favicon.png";
                      updateInterval = 24 * 60 * 60 * 1000; # every day
                      definedAliases = [ "@nw" ];
                    };

                    "Bing".metaData.hidden = true;
                    "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
                  }
                '';
                description = ''
                  Attribute set of search engine configurations. Engines
                  that only have <varname>metaData</varname> specified will
                  be treated as builtin to Firefox.
                  </para><para>
                  See <link xlink:href=
                  "https://searchfox.org/mozilla-central/rev/669329e284f8e8e2bb28090617192ca9b4ef3380/toolkit/components/search/SearchEngine.jsm#1138-1177">SearchEngine.jsm</link>
                  in Firefox's source for available options. We maintain a
                  mapping to let you specify all options in the referenced
                  link without underscores, but it may fall out of date with
                  future options.
                  </para><para>
                  Note, <varname>icon</varname> is also a special option
                  added by Home Manager to make it convenient to specify
                  absolute icon paths.
                '';
              };
            };

            extensions = mkOption {
              type = types.listOf types.package;
              default = [ ];
              example = literalExpression ''
                with pkgs.nur.repos.rycee.firefox-addons; [
                  privacy-badger
                ]
              '';
              description = ''
                List of Firefox add-on packages to install for this profile.
                Some pre-packaged add-ons are accessible from NUR,
                <link xlink:href="https://github.com/nix-community/NUR"/>.
                Once you have NUR installed run

                <screen language="console">
                  <prompt>$</prompt> <userinput>nix-env -f '&lt;nixpkgs&gt;' -qaP -A nur.repos.rycee.firefox-addons</userinput>
                </screen>

                to list the available Firefox add-ons.

                </para><para>

                Note that it is necessary to manually enable these extensions
                inside Firefox after the first installation.
              '';
            };

          };
        }));
        default = { };
        description = "Attribute set of Firefox profiles.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (let
        defaults =
          catAttrs "name" (filter (a: a.isDefault) (attrValues cfg.profiles));
      in {
        assertion = cfg.profiles == { } || length defaults == 1;
        message = "Must have exactly one default Firefox profile but found "
          + toString (length defaults) + optionalString (length defaults > 1)
          (", namely " + concatStringsSep ", " defaults);
      })

      (let
        duplicates = filterAttrs (_: v: length v != 1) (zipAttrs
          (mapAttrsToList (n: v: { "${toString v.id}" = n; }) (cfg.profiles)));

        mkMsg = n: v: "  - ID ${n} is used by ${concatStringsSep ", " v}";
      in {
        assertion = duplicates == { };
        message = ''
          Must not have Firefox profiles with duplicate IDs but
        '' + concatStringsSep "\n" (mapAttrsToList mkMsg duplicates);
      })
    ];

    warnings = optional (cfg.enableGnomeExtensions or false) ''
      Using 'programs.mullvad-browser.enableGnomeExtensions' has been deprecated and
      will be removed in the future. Please change to overriding the package
      configuration using 'programs.mullvad-browser.package' instead. You can refer to
      its example for how to do this.
    '';

    home.packages = [ cfg.package ] ++ (if cfg.createProfileBins then
      (mapAttrsToList (name: profile: (mkProfileBin name))
        (filterAttrs (_: p: !p.isDefault) cfg.profiles))
    else
      [ ]);

    home.file = mkMerge ([{
      "${dataConfigPath}/profiles.ini" =
        mkIf (cfg.profiles != { }) { text = profilesIni; };
    }] ++ flip mapAttrsToList cfg.profiles (_: profile: {
      "${profilesPath}/${profile.path}/.keep".text = "";

      "${profilesPath}/${profile.path}/chrome/userChrome.css" =
        mkIf (profile.userChrome != "") { text = profile.userChrome; };

      "${profilesPath}/${profile.path}/chrome/userContent.css" =
        mkIf (profile.userContent != "") { text = profile.userContent; };

      "${profilesPath}/${profile.path}/user.js" = mkIf (profile.settings != { }
        || profile.extraConfig != "" || profile.bookmarks != [ ]) {
          text =
            mkUserJs profile.settings profile.extraConfig profile.bookmarks;
        };

      "${profilesPath}/${profile.path}/search.json.mozlz4" = mkIf
        (profile.search.default != null || profile.search.order != [ ]
          || profile.search.engines != { }) {
            force = profile.search.force;
            source = let
              settings = {
                version = 6;
                engines = let
                  # Map of nice field names to internal field names.
                  # This is intended to be exhaustive and should be
                  # updated at every version bump.
                  internalFieldNames = (genAttrs [
                    "name"
                    "isAppProvided"
                    "loadPath"
                    "hasPreferredIcon"
                    "updateInterval"
                    "updateURL"
                    "iconUpdateURL"
                    "iconURL"
                    "iconMapObj"
                    "metaData"
                    "orderHint"
                    "definedAliases"
                    "urls"
                  ] (name: "_${name}")) // {
                    searchForm = "__searchForm";
                  };

                  processCustomEngineInput = input:
                    (removeAttrs input [ "icon" ])
                    // optionalAttrs (input ? icon) {
                      # Convenience to specify absolute path to icon
                      iconURL = "file://${input.icon}";
                    } // (optionalAttrs (input ? iconUpdateURL) {
                      # Convenience to default iconURL to iconUpdateURL so
                      # the icon is immediately downloaded from the URL
                      iconURL = input.iconURL or input.iconUpdateURL;
                    } // {
                      # Required for custom engine configurations, loadPaths
                      # are unique identifiers that are generally formatted
                      # like: [source]/path/to/engine.xml
                      loadPath = ''
                        [home-manager]/programs.mullvad-browser.profiles.${profile.name}.search.engines."${
                          replaceStrings [ "\\" ] [ "\\\\" ] input.name
                        }"'';
                    });

                  processEngineInput = name: input:
                    let
                      requiredInput = {
                        inherit name;
                        isAppProvided = input.isAppProvided or removeAttrs input
                          [ "metaData" ] == { };
                        metaData = input.metaData or { };
                      };
                    in if requiredInput.isAppProvided then
                      requiredInput
                    else
                      processCustomEngineInput (input // requiredInput);

                  buildEngineConfig = name: input:
                    mapAttrs' (name: value: {
                      name = internalFieldNames.${name} or name;
                      inherit value;
                    }) (processEngineInput name input);

                  sortEngineConfigs = configs:
                    let
                      buildEngineConfigWithOrder = order: name:
                        let
                          config = configs.${name} or {
                            _name = name;
                            _isAppProvided = true;
                            _metaData = { };
                          };
                        in config // {
                          _metaData = config._metaData // { inherit order; };
                        };

                      engineConfigsWithoutOrder =
                        attrValues (removeAttrs configs profile.search.order);

                      sortedEngineConfigs =
                        (imap buildEngineConfigWithOrder profile.search.order)
                        ++ engineConfigsWithoutOrder;
                    in sortedEngineConfigs;

                  engineInput = profile.search.engines // {
                    # Infer profile.search.default as an app provided
                    # engine if it's not in profile.search.engines
                    ${profile.search.default} =
                      profile.search.engines.${profile.search.default} or { };
                  };
                in sortEngineConfigs (mapAttrs buildEngineConfig engineInput);

                metaData = optionalAttrs (profile.search.default != null) {
                  current = profile.search.default;
                  hash = "@hash@";
                } // {
                  useSavedOrder = profile.search.order != [ ];
                };
              };

              # Home Manager doesn't circumvent user consent and isn't acting
              # maliciously. We're modifying the search outside of Firefox, but
              # a claim by Mozilla to remove this would be very anti-user, and
              # is unlikely to be an issue for our use case.
              disclaimer = appName:
                "By modifying this file, I agree that I am doing so "
                + "only within ${appName} itself, using official, user-driven search "
                + "engine selection processes, and in a way which does not circumvent "
                + "user consent. I acknowledge that any attempt to change this file "
                + "from outside of ${appName} is a malicious act, and will be responded "
                + "to accordingly.";

              salt = if profile.search.default != null then
                profile.path + profile.search.default + disclaimer "Firefox"
              else
                null;
            in pkgs.runCommand "search.json.mozlz4" {
              nativeBuildInputs = with pkgs; [ mozlz4a openssl ];
              json = builtins.toJSON settings;
              inherit salt;
            } ''
              if [[ -n $salt ]]; then
                export hash=$(echo -n "$salt" | openssl dgst -sha256 -binary | base64)
                mozlz4a <(substituteStream json search.json.in --subst-var hash) "$out"
              else
                mozlz4a <(echo "$json") "$out"
              fi
            '';
          };

      "${profilesPath}/${profile.path}/extensions" =
        mkIf (profile.extensions != [ ]) {
          source = let
            extensionsEnvPkg = pkgs.buildEnv {
              name = "hm-mullvad-browser-extensions";
              paths = profile.extensions;
            };
          in "${extensionsEnvPkg}/share/mozilla/${extensionPath}";
          recursive = true;
          force = true;
        };
    }));
  };
}
