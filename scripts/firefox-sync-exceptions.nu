#! /usr/bin/env nu

# Synchronizes site data & cookie exceptions for Firefox-based browsers
# with a TOML config file.
#
# Run without arguments for an interactive session (select browser, profile &
# config, then choose which changes to apply).
# For non-interactive use pass --browser & --config; all configured profiles
# are then synced and --yes applies every change without confirmation.

# get origin & origin attributes separately from single origin string
def split_origin []: string -> record {
  let x = $in | split column '^' origin attrs | into record
  let attrs = if $x.attrs? != null {
    $x.attrs | split row '&' | each {|attr| $attr | split row '='} | into record
  } else { {} }
  { origin: $in origin_short: $x.origin } | merge $attrs
}

# show the differences between the configured exceptions and the browser's
# permissions.sqlite & apply the selected changes
def sync-exceptions [
  db_file: string,
  exceptions: list<string>,
  --yes  # apply all changes without confirmation
] {
  let db = $db_file | open

  let exceptions_db = $db | get moz_perms
    | where type == "cookie" and permission == 1 and expireType == 0 and expireTime == 0
    | each {|x| $x | merge ($x.origin | split_origin) }
  let exceptions_config = $exceptions | each {|origin| $origin | split_origin }

  let exceptions_to_insert = $exceptions_config
    | where {|x| ($exceptions_db | where origin_short == $x.origin_short | length) == 0 }
    | each {|x| { origin: $x.origin } }
  let exceptions_to_update = $exceptions_config
    | each {|x|
      let results = $exceptions_db | where origin_short == $x.origin_short and origin != $x.origin
      let result = $results.0?
      if $result != null {
        { id: $result.id origin: $x.origin origin_old: $result.origin }
      } else { null }
    }
    | compact
  let exceptions_to_delete = $exceptions_db
    | where {|x| ($exceptions_config | where origin_short == $x.origin_short | length) == 0 }
    | each {|x| { id: $x.id origin: $x.origin } }

  let needs_insert = ($exceptions_to_insert | length) > 0
  let needs_update = ($exceptions_to_update | length) > 0
  let needs_delete = ($exceptions_to_delete | length) > 0

  if not ($needs_insert or $needs_update or $needs_delete) {
    print "No changes necessary"
    return
  }

  mut available_actions = []

  if $needs_insert {
    print "Exceptions to insert:"
    print $exceptions_to_insert
    $available_actions = ($available_actions | append "insert")
  }

  if $needs_update {
    print "Exceptions to update:"
    print $exceptions_to_update
    $available_actions = ($available_actions | append "update")
  }

  if $needs_delete {
    print "Exceptions to delete:"
    print $exceptions_to_delete
    $available_actions = ($available_actions | append "delete")
  }

  let actions = if $yes {
    $available_actions
  } else {
    $available_actions | input list --multi "Which of the changes above should be applied?"
  }

  if ($actions | length) == 0 {
    print "Not applying any changes"
    return
  }

  let time = (date now | into int) / 1000000 | into int

  if $needs_insert and "insert" in $actions {
    $exceptions_to_insert | each {|x|
      $db | query db '
        INSERT INTO moz_perms (origin, type, permission, expireType, expireTime, modificationTime)
        VALUES (:origin, "cookie", 1, 0, 0, :time)
      ' --params { origin: $x.origin time: $time }
    }
    print "Successfully inserted new records"
  }

  if $needs_update and "update" in $actions {
    $exceptions_to_update | each {|x|
      $db | query db '
        UPDATE moz_perms
        SET origin = :origin, modificationTime = :time
        WHERE id = :id
      ' --params { id: $x.id origin: $x.origin time: $time }
    }
    print "Successfully updated changed records"
  }

  if $needs_delete and "delete" in $actions {
    $exceptions_to_delete | each {|x|
      $db | query db 'DELETE FROM moz_perms WHERE id = :id' --params { id: $x.id }
    }
    print "Successfully deleted missing records"
  }
}

def main [
  --browser: string = ""  # browser profile base directory, e.g. ~/.mozilla/firefox
  --config: string = ""   # TOML config mapping profile names to exception origins
  --profile: string = ""  # sync only this profile (default: all profiles in the config)
  --yes                   # apply all changes without confirmation
] {
  if $browser == "" and $config == "" {
    print "This script synchronizes site data & cookie exceptions for Firefox-based browsers with a TOML config file."

    let browsers = [
      { name: "Mullvad Browser" path: "~/.mullvad/mullvadbrowser" }
      { name: "Tor Browser" path: "~/.tor project/firefox" }
      { name: "Firefox" path: "~/.mozilla/firefox" }
    ]
    let browser = $browsers | input list --display name --fuzzy "Select your browser"

    print $"Looking for profiles in ($browser.path)"
    let profiles = ls --short-names ...(glob $browser.path) | where type == "dir" | get name
    let profile = $profiles | input list --fuzzy "Select the profile you want to change"

    let config_types = [
      [id name default_path];
      ["toml" "TOML" "secrets/firefox/site-data-exceptions.toml"]
      ["toml-age" "TOML (age-encrypted)" "firefox/site-data-exceptions.toml.age"]
    ]
    let config_type = $config_types | input list --display name --fuzzy "Select your config type"

    let agenix_path = match $config_type.id {
      "toml" => { },
      "toml-age" => { input --default "secrets" "Select your agenix path (location of `secrets.nix`)" },
    }

    let config_file = input --default $config_type.default_path "Select your config file"
    let config_file = match $config_type.id {
      "toml" => { $config_file },
      "toml-age" => { $config_file | str replace -r $"^($agenix_path)/" '' },
    }

    let config = match $config_type.id {
      "toml" => { open --raw $config_file | from toml },
      "toml-age" => { (cd $agenix_path; agenix -d $config_file) | from toml },
    }

    sync-exceptions $"($browser.path)/($profile)/permissions.sqlite" ($config | get $profile)
  } else {
    if $browser == "" or $config == "" {
      error make {
        msg: "--browser and --config must be passed together (or neither for interactive mode)"
      }
    }

    # HINT open detects the format from the file extension; the config file
    # may not have one (e.g. agenix secrets in /run/agenix), so parse explicitly
    let config_data = open --raw $config | from toml
    let profiles = if $profile == "" { $config_data | columns } else { [$profile] }

    for profile in $profiles {
      let db_file = $"($browser)/($profile)/permissions.sqlite"
      if not ($db_file | path exists) {
        print $"Skipping profile ($profile): ($db_file) does not exist"
        continue
      }
      print $"== ($profile) =="
      sync-exceptions $db_file ($config_data | get $profile) --yes=$yes
    }
  }
}
